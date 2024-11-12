import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/repositories/restaurant_repository.dart';
import 'package:geocoding/geocoding.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jom_makan/constants/options.dart';


class ManageProfilePage extends StatefulWidget {
  final String restaurantId;
  const ManageProfilePage({Key? key, required this.restaurantId}) : super(key: key);

  @override
  _ManageProfilePageState createState() => _ManageProfilePageState();
}

class _ManageProfilePageState extends State<ManageProfilePage> {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  bool _isLoading = true;
  Restaurant? _restaurant;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _introController = TextEditingController();

  List<String> _selectedCuisineTypes = [];
  List<String> _selectedTags = [];
  File? _profileImage;

  Map<String, TimeOfDay> _openTimes = {};
  Map<String, TimeOfDay> _closeTimes = {};

  final List<String> _cuisineOptions = cuisineOptions;

  final List<String> _tagOptions = tagOptions;

     final List<String> _daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _fetchRestaurantData();
  }



  Future<void> _fetchRestaurantData() async {
    try {
      _restaurant = await _restaurantRepository.getRestaurantData(widget.restaurantId);
      if (_restaurant == null) throw Exception("Restaurant data not found.");

      _nameController.text = _restaurant!.name;
      _introController.text = _restaurant!.intro;
      _locationController.text = await _getAddressFromLatLng(_restaurant!.location.latitude, _restaurant!.location.longitude);
      _selectedCuisineTypes = List.from(_restaurant!.cuisineType);
      _selectedTags = List.from(_restaurant!.tags);

      _restaurant!.operatingHours.forEach((day, hours) {
        _openTimes[day] = _parseTimeOfDay(hours.openTime);
        _closeTimes[day] = _parseTimeOfDay(hours.closeTime);
      });

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error fetching restaurant data: $e");
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<String> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) {
        return "Unknown Location";
      }

      Placemark place = placemarks[0];

      // Only add parts that are non-null and non-empty
      List<String> addressParts = [
        if (place.street != null && place.street!.isNotEmpty) place.street!,
        if (place.subLocality != null && place.subLocality!.isNotEmpty) place.subLocality!,
        if (place.locality != null && place.locality!.isNotEmpty) place.locality!,
        if (place.postalCode != null && place.postalCode!.isNotEmpty) place.postalCode!,
        if (place.country != null && place.country!.isNotEmpty) place.country!,
      ];

      // Join non-null parts with commas
      return addressParts.join(', ');
    } catch (e) {
      print("Error getting address: $e");
      return "Unknown Location";
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    // Check if the location field text has changed
    final bool locationChanged = _locationController.text != await _getAddressFromLatLng(
      _restaurant!.location.latitude,
      _restaurant!.location.longitude,
    );

    // Use the existing geoLocation unless location has been edited
    final GeoPoint geoLocation = locationChanged
        ? await _getGeoPoint(_locationController.text)
        : _restaurant!.location;

    final Map<String, OperatingHours> updatedOperatingHours = {
      for (var day in _openTimes.keys)
        day: OperatingHours(
          openTime: _formatTime(_openTimes[day]!),
          closeTime: _formatTime(_closeTimes[day]!),
        )
    };

    bool success = await _restaurantRepository.updateRestaurantProfile(
      restaurantId: widget.restaurantId,
      name: _nameController.text,
      location: geoLocation,
      cuisineType: _selectedCuisineTypes,
      operatingHours: updatedOperatingHours,
      intro: _introController.text,
      tags: _selectedTags,
    );

    if (success) {
      if (_profileImage != null) {
        String newImageUrl = await _uploadNewProfileImage();
        await _restaurantRepository.updateRestaurantProfileImage(widget.restaurantId, newImageUrl);
      }
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile.")),
      );
    }
  }

  Future<GeoPoint> _getGeoPoint(String address) async {
    List<Location> locations = await locationFromAddress(address);
    return GeoPoint(locations.first.latitude, locations.first.longitude);
  }

  String _formatTime(TimeOfDay time) => '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  TimeOfDay _parseTimeOfDay(String time) => TimeOfDay(hour: int.parse(time.split(":")[0]), minute: int.parse(time.split(":")[1]));

Future<String> _uploadNewProfileImage() async {
  try {
    final storageRef = FirebaseStorage.instance.ref();

    // Delete the old image from Firebase Storage
    if (_restaurant?.image != null && _restaurant!.image.isNotEmpty) {
      try {
        // Create a reference to the old image path
        final oldImageRef = _restaurant!.image!;  // Assuming image URL contains the storage path
        await _deleteImage(oldImageRef); // Call the delete function with the correct image URL
        print("Old image deleted successfully.");
      } catch (e) {
        print("Error deleting old image: $e");
      }
    }

    // Upload the new image
    final fileName = DateTime.now().millisecondsSinceEpoch.toString(); // Use timestamp for unique filename
    final profileImageRef = storageRef.child('restaurant_images/${widget.restaurantId}/$fileName');
    final uploadTask = profileImageRef.putFile(_profileImage!);

    // Wait for the upload to complete
    await uploadTask;

    // Get the download URL
    String downloadUrl = await profileImageRef.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    throw Exception("Failed to upload image: $e");
  }
}

Future<void> _deleteImage(String imageUrl) async {
  try {
    final Uri url = Uri.parse(imageUrl);
    final String imageFileName = url.pathSegments.last;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('$imageFileName');

    await storageRef.delete();

    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .update({
      'menu': FieldValue.arrayRemove([imageUrl]),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image deleted successfully')),
    );

    // // Navigate back to the main page
    // Navigator.of(context).pop();

  } catch (e) {
    print("Error deleting image: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to delete image')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Restaurant Profile"), backgroundColor: Color.fromARGB(255, 192, 190, 91)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickProfileImage,
                    child: CircleAvatar(
                      radius: 75,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : NetworkImage(_restaurant!.image) as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Restaurant Name"),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _introController,
                    decoration: const InputDecoration(labelText: "Intro"),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: "Location"),
                  ),
                  const SizedBox(height: 16),
                  // Cuisine Type Multi-Select
                  MultiselectDropdown(
                    options: _cuisineOptions,
                    selectedItems: _selectedCuisineTypes,
                    onChanged: (selectedItems) {
                      setState(() {
                        _selectedCuisineTypes = selectedItems;
                      });
                    },
                    label: "Cuisine Type",
                  ),
                  const SizedBox(height: 16),
                  // Tags Multi-Select
                  MultiselectDropdown(
                    options: _tagOptions,
                    selectedItems: _selectedTags,
                    onChanged: (selectedItems) {
                      setState(() {
                        _selectedTags = selectedItems;
                      });
                    },
                    label: "Tags",
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: _daysOfWeek.map((day) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(day),
                          TextButton(
                            onPressed: () async {
                              final openTime = await showTimePicker(context: context, initialTime: _openTimes[day]!);
                              if (openTime != null) setState(() => _openTimes[day] = openTime);
                            },
                            child: Text("Open: ${_formatTime(_openTimes[day]!)}"),
                          ),
                          TextButton(
                            onPressed: () async {
                              final closeTime = await showTimePicker(context: context, initialTime: _closeTimes[day]!);
                              if (closeTime != null) setState(() => _closeTimes[day] = closeTime);
                            },
                            child: Text("Close: ${_formatTime(_closeTimes[day]!)}"),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: const Text("Save Changes"),
                  ),
                ],
              ),
            ),
    );
  }
}

class MultiselectDropdown extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> selectedItems;
  final Function(List<String>) onChanged;

  const MultiselectDropdown({
    Key? key,
    required this.label,
    required this.options,
    required this.selectedItems,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      child: MultiSelectDialogField(
        initialValue: selectedItems,
        items: options.map((option) => MultiSelectItem(option, option)).toList(),
        onConfirm: onChanged,
      ),
    );
  }
}

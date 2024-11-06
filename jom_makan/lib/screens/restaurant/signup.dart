import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:jom_makan/models/operatingHours.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/providers/auth_provider.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_buttons.dart';
import 'package:jom_makan/widgets/custom_text.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RestaurantSignUp extends StatefulWidget {
  RestaurantSignUp({super.key});

  @override
  _RestaurantSignUpState createState() => _RestaurantSignUpState();
}

class _RestaurantSignUpState extends State<RestaurantSignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _introController = TextEditingController();
  

  List<String> _selectedCuisineTypes = [];
  List<File> _menuImages = [];
  List<String> _selectedTags = [];
  File? _profileImage;

  // Separate maps for opening and closing times
  Map<String, TimeOfDay?> _openTimes = {
    'Monday': null,
    'Tuesday': null,
    'Wednesday': null,
    'Thursday': null,
    'Friday': null,
    'Saturday': null,
    'Sunday': null,
  };

  Map<String, TimeOfDay?> _closeTimes = {
    'Monday': null,
    'Tuesday': null,
    'Wednesday': null,
    'Thursday': null,
    'Friday': null,
    'Saturday': null,
    'Sunday': null,
  };

  final List<String> _cuisineOptions = [
    'Italian', 'Chinese', 'Indian', 'Mexican', 'Thai', 
    'Japanese', 'French', 'Mediterranean', 'American', 'Lebanese', 
    'Spanish', 'Greek', 'Turkish', 'Korean', 'Vietnamese',
    'Brazilian', 'Moroccan', 'Caribbean', 'German', 'Russian'
  ];

  final List<String> _tagOptions = [
  'Fish Allergic Free', 'Prawn Allergic Free', 'Pork Free', 'Halal', 
  'Vegetarian', 'Vegan', 'Gluten Free', 'Nut Free', 
  'Dairy Free', 'Egg Free', 'Soy Free', 'Kosher', 
  'Organic', 'Locally Sourced', 'Low Carb', 'Low Sugar',
  'Keto Friendly', 'High Protein', 'Family Friendly', 'Pet Friendly'
  ];

  Future<void> _selectOpenTime(BuildContext context, String day) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _openTimes[day] ?? TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        _openTimes[day] = selectedTime;
      });
    }
  }

  Future<void> _selectCloseTime(BuildContext context, String day) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _closeTimes[day] ?? TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        _closeTimes[day] = selectedTime;
      });
    }
  }

  Future<void> _pickMenuImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _menuImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<GeoPoint> _getGeoPoint(String location) async {
    List<Location> locations = await locationFromAddress(location);
    return GeoPoint(locations.first.latitude, locations.first.longitude);
  }

  Future<List<String>> _uploadImages(List<File> images) async {
    List<String> imageUrls = [];
    for (var image in images) {
      Reference ref = FirebaseStorage.instance.ref().child("menuImages/${image.path.split('/').last}");
      await ref.putFile(image);
      String downloadUrl = await ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      title: 'Error',
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.background),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text("Welcome, Register Your Restaurant!", style: AppTextStyles.authHead),
              const SizedBox(height: 30),

              // Profile Image Upload
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Upload Profile Image:", style: GoogleFonts.poppins(fontSize: 14)),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickProfileImage,
                child: _profileImage != null
                    ? CircleAvatar(radius: 50, backgroundImage: FileImage(_profileImage!))
                    : CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.camera_alt, size: 50, color: Colors.grey[700]),
                      ),
              ),
              const SizedBox(height: 20),

              CustomTextFormField(
                controller: _nameController,
                placeholderText: 'Restaurant Name',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _locationController,
                placeholderText: 'Location',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _emailController,
                placeholderText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _passwordController,
                placeholderText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // Cuisine Type Selection
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Select Cuisine Types:", style: GoogleFonts.poppins(fontSize: 14)),
              ),
              SizedBox(
                height: 60, // Adjust height as needed for visibility
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _selectedCuisineTypes.map((cuisine) {
                      return Chip(
                        label: Text(cuisine),
                        deleteIcon: Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            _selectedCuisineTypes.remove(cuisine);
                          });
                        },
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CustomDropdown(
                options: _cuisineOptions,
                selectedOptions: _selectedCuisineTypes,
                onChanged: (List<String> selected) {
                  setState(() {
                    _selectedCuisineTypes = selected;
                  });
                },
              ),
              const SizedBox(height: 20),
               // Introduction Input
              CustomTextFormField(
                controller: _introController,
                placeholderText: 'Introduction (About the restaurant)',
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Select Tags:", style: GoogleFonts.poppins(fontSize: 14)),
              ),
              SizedBox(
                height: 60, // Adjust height as needed for visibility
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _selectedTags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        deleteIcon: Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            _selectedTags.remove(tag);
                          });
                        },
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CustomDropdown(
                options: _tagOptions,
                selectedOptions: _selectedTags,
                onChanged: (List<String> selected) {
                  setState(() {
                    _selectedTags = selected;
                  });
                },
              ),
              const SizedBox(height: 20),
              
              // Operating Hours
              Text("Select Operating Hours:", style: AppTextStyles.authHead),
              const SizedBox(height: 10),
              Column(
                children: _openTimes.keys.map((day) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(day),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => _selectOpenTime(context, day),
                                child: Text(
                                  _openTimes[day]?.format(context) ?? 'Open Time',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              Text(' - '),
                              TextButton(
                                onPressed: () => _selectCloseTime(context, day),
                                child: Text(
                                  _closeTimes[day]?.format(context) ?? 'Close Time',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Menu Image Upload
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Upload Menu Images:", style: GoogleFonts.poppins(fontSize: 14)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickMenuImage,
                child: Text("Add Menu Image"),
              ),
              const SizedBox(height: 10),
              // Display selected menu images
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _menuImages.map((image) {
                  return Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(image, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _menuImages.remove(image);
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Register Button
              CustomPrimaryButton(
                text: "Register",
                onPressed: () async {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();
                  final name = _nameController.text.trim();
                  final location = _locationController.text.trim();
                  final intro = _introController.text.trim();

                  if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty && location.isNotEmpty) {
                    if (password.length > 5) {
                      try {
                        // Get GeoPoint from location
                        GeoPoint geoPoint = await _getGeoPoint(location);

                        // Collect operating hours
                        Map<String, OperatingHours> operatingHours = {};
                        _openTimes.forEach((day, openTime) {
                          final closeTime = _closeTimes[day];
                          if (openTime != null && closeTime != null) {
                            operatingHours[day] = OperatingHours(
                              openTime: openTime.format(context),
                              closeTime: closeTime.format(context),
                            );
                          }
                        });

                        // Call the signUpRestaurantWithEmail method
                        await authProvider.signUpRestaurantWithEmail(
                          email: email,
                          password: password,
                          name: name,
                          location: geoPoint,
                          cuisineType: _selectedCuisineTypes,
                          menu: [], // Assuming you handle menu items elsewhere
                          operatingHours: operatingHours,
                          intro: intro,
                          menuImages: _menuImages,
                          tags: _selectedTags,
                          profileImage: _profileImage,
                        );

                        // Show success dialog
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.success,
                          title: 'Registration Successful',
                          desc: 'Your restaurant has been registered successfully!',
                          btnOkOnPress: () {
                            Navigator.pop(context);
                          },
                        ).show();
                      } catch (e) {
                        print(e);
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          title: 'Registration Failed',
                          desc: 'An error occurred while registering your restaurant. Please try again.',
                          btnOkOnPress: () {},
                        ).show();
                      }
                    } else {
                      _showErrorDialog('Password must be at least 6 characters.');
                    }
                  } else {
                    _showErrorDialog('Please fill in all fields.');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

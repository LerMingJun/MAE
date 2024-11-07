import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({super.key});

  @override
  _AddRestaurantScreenState createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  final nameController = TextEditingController();
  final introController = TextEditingController();
  final addressController = TextEditingController();
  final cuisineTypeController = TextEditingController();
  final menuController = TextEditingController();
  final tagsController = TextEditingController();

  double rating = 0.0;

  @override
  void dispose() {
    // Dispose controllers
    nameController.dispose();
    introController.dispose();
    addressController.dispose();
    cuisineTypeController.dispose();
    menuController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  // Function to convert address to coordinates
  Future<GeoPoint?> _getCoordinates(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return GeoPoint(locations[0].latitude, locations[0].longitude);
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  // Function to add restaurant to Firestore
  Future<void> _addRestaurant() async {
    if (_formKey.currentState!.validate()) {
      GeoPoint? location = await _getCoordinates(addressController.text);
      if (location == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to find location for the provided address')),
        );
        return;
      }

      List<String> cuisineTypes = cuisineTypeController.text.split(',').map((e) => e.trim()).toList();
      List<String> tags = tagsController.text.split(',').map((e) => e.trim()).toList();

      Map<String, List<String>> menu = {
        'main': menuController.text.split(',').map((e) => e.trim()).toList()
      };

      await FirebaseFirestore.instance.collection('restaurants').add({
        'name': nameController.text,
        'location': location,
        'cuisineType': cuisineTypes,
        'menu': menu,
        'operatingHours': {
          'monday': {'open': '9:00', 'close': '21:00'},
        },
        'intro': introController.text,
        'tags': tags,
        'image': "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restaurant added successfully!')),
      );

      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Restaurant')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Restaurant Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a name';
                    return null;
                  },
                ),
                TextFormField(
                  controller: introController,
                  decoration: const InputDecoration(labelText: 'Introduction'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter an introduction';
                    return null;
                  },
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter an address';
                    return null;
                  },
                ),
                TextFormField(
                  controller: cuisineTypeController,
                  decoration: const InputDecoration(labelText: 'Cuisine Types (comma-separated)'),
                ),
                TextFormField(
                  controller: menuController,
                  decoration: const InputDecoration(labelText: 'Menu Items (comma-separated)'),
                ),
                TextFormField(
                  controller: tagsController,
                  decoration: const InputDecoration(labelText: 'Tags (comma-separated)'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addRestaurant,
                  child: const Text('Add Restaurant'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jom_makan/constants/placeholderURL.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_buttons.dart';
import 'package:jom_makan/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  List<String> _selectedPreferences = [];
  final List<String> _preferencesOptions = [
    'Italian',
    'Chinese',
    'Indian',
    'Mexican',
    'Thai',
    'French',
    'Japanese',
    'Korean',
    'Vietnamese',
    'Vegetarian',
    'Vegan',
    'Gluten-free',
    'Prawn Allergy',
    'Egg Allergy',
    'Fish Allergy',
    'Shellfish Allergy',
    'Dairy Allergy',
    'Soy Allergy',
  ];

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.userData;
    if (user != null) {
      _fullNameController.text = user.fullName;
      _usernameController.text = user.username;
      _emailController.text = user.email; // Set email for display
      _selectedPreferences =
          user.dietaryPreferences; // Assuming user has a preferences field
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  width: 120,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3.0),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _image == null
                              ? NetworkImage(
                                  userProvider.userData?.profileImage ??
                                      userPlaceholder) as ImageProvider
                              : FileImage(File(_image!.path)),
                        ),
                      ),
                      Positioned(
                        bottom: -3,
                        right: -12,
                        child: Container(
                          child: ElevatedButton(
                            onPressed: () {
                              getImage();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.primary,
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _fullNameController,
                placeholderText: 'Full Name',
                keyboardType: TextInputType.name,
                onChanged: (value) {},
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _usernameController,
                placeholderText: 'Username',
                keyboardType: TextInputType.name,
                onChanged: (value) {},
              ),
              const SizedBox(height: 20),
              // Displaying email without allowing changes
              CustomTextFormField(
                controller: _emailController,
                placeholderText: 'Email',
                enabled: false, // Disable editing
                onChanged: (value) {}, // Keep the onChanged for compatibility
              ),
              const SizedBox(height: 20),
              // Preferences Selection
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select Your Preferences:",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _selectedPreferences.map((preference) {
                  return Chip(
                    label: Text(preference),
                    onDeleted: () {
                      setState(() {
                        _selectedPreferences.remove(preference);
                      });
                    },
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),

              // Custom Scrollable Dropdown for preferences
              CustomDropdown(
                options: _preferencesOptions,
                selectedOptions: _selectedPreferences,
                onChanged: (List<String> selected) {
                  setState(() {
                    _selectedPreferences = selected;
                  });
                },
              ),
              const SizedBox(height: 50),
              CustomPrimaryButton(
                  onPressed: () {
                    if (_fullNameController.text.isNotEmpty &&
                        _usernameController.text.isNotEmpty) {
                      _updateProfile();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all fields.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  text: "Update")
            ],
          ),
        ),
      ),
    );
  }

  Future getImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    setState(() {
      _image = image;
    });
  }

  Future<void> _updateProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final data = {
      'fullName': _fullNameController.text.trim(),
      'username': _usernameController.text.trim(),
      'dietaryPreferences': _selectedPreferences,
    };
    await userProvider.updateUserData(data, _image);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

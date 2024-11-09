import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jom_makan/models/community.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/providers/post_provider.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jom_makan/widgets/custom_buttons.dart';
import 'package:provider/provider.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController =
      TextEditingController(); // Added for tags
  String? selectedActivity;
  XFile? _image;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose(); // Dispose tags controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Share your ',
                style: GoogleFonts.lato(fontSize: 24),
              ),
              TextSpan(
                text: 'Thoughts!',
                style: GoogleFonts.lato(
                  fontSize: 24,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _image == null
                    ? const Text('No image selected.')
                    : Image.file(
                        File(_image!.path),
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: getImage,
                      icon:
                          const Icon(Icons.image_outlined, color: AppColors.primary),
                      label: Text(
                        'Pick an Image',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.primary),
                      ),
                    ),
                    Text(
                      ' or ',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    TextButton.icon(
                      onPressed: getImageFromCamera,
                      icon: const Icon(Icons.camera_alt_outlined,
                          color: AppColors.primary),
                      label: Text(
                        'Take A Picture',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.black, thickness: 1),
                SizedBox(
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'Your Title Here...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.placeholder),
                      maxLines: null,
                      expands: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const Divider(color: Colors.black, thickness: 1),
                SizedBox(
                  height: 200,
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Description here...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.placeholder),
                    maxLines: null,
                    expands: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                ),
                const Divider(color: Colors.black, thickness: 1),
                SizedBox(
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        hintText: 'Tags (comma separated)...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.placeholder),
                      maxLines: null,
                      expands: true,
                    ),
                  ),
                ),
                const Divider(color: Colors.black, thickness: 1),
                const SizedBox(height: 10),
                CustomPrimaryButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _image != null) {
                      _addPost();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please fill out all fields and select an image'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  text: "Share",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future getImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  Future<void> _addPost() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    // Prepare the post data
    List<String> tags =
        _tagsController.text.split(',').map((tag) => tag.trim()).toList();

    // Fetch the userId and userRole from your user provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String userId = userProvider
        .userData!.userID; // Assuming you have a currentUser property
    String userRole = "User"; // Assuming the user model has a role property

    CommunityPost newPost = CommunityPost(
      postId: '', // This will be generated by Firestore
      userId: userId,
      userRole: userRole,
      title: _titleController.text.trim(),
      content: _descriptionController.text,
      likes: 0, // Start with 0 likes
      tags: tags,
      timestamp: Timestamp.now(),
    );

    // Call your postProvider method to add the post
    await postProvider.addPost(
        _image, newPost.title, newPost.content, newPost.tags);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post Shared!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/providers/post_provider.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jom_makan/widgets/custom_buttons.dart';
import 'package:jom_makan/widgets/custom_loading.dart';
import 'package:provider/provider.dart';

class EditPost extends StatefulWidget {
  const EditPost({super.key});

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String? selectedActivity;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _titleController.text = args['currentTitle'];
      _descriptionController.text = args['currentDescription'];
      _tagsController.text = args['currentTags'].join(', ');
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Edit your ', style: GoogleFonts.lato(fontSize: 24)),
              TextSpan(
                text: 'Post!',
                style: GoogleFonts.lato(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.bold),
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
                    ? Image.network(
                        args['postImage'] ?? 'defaultImageURL' , 
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const CustomImageLoading(width: 300);
                        },
                      )
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
                      icon: const Icon(Icons.image_outlined, color: AppColors.primary),
                      label: Text(
                        'Pick an Image',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primary),
                      ),
                    ),
                    Text(' or ', style: GoogleFonts.poppins(fontSize: 12)),
                    TextButton.icon(
                      onPressed: getImageFromCamera,
                      icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                      label: Text(
                        'Take A Picture',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.black, thickness: 1),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Your Title Here...',
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.placeholder),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const Divider(color: Colors.black, thickness: 1),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Description here...',
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.placeholder),
                  maxLines: null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const Divider(color: Colors.black, thickness: 1),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    hintText: 'Tags (comma separated)...',
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.placeholder),
                ),
                const Divider(color: Colors.black, thickness: 1),
                CustomPrimaryButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _updatePost();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill out all fields.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  text: "Edit Post",
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

  void _updatePost() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    List<String> tags = _tagsController.text.split(',').map((tag) => tag.trim()).toList();

    await postProvider.updatePost(
      args['postID'],
      _image,
      _titleController.text.trim(),
      _descriptionController.text,
      tags,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post updated successfully!'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }
}

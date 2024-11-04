import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:jom_makan/providers/participation_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/providers/event_provider.dart';
import 'package:jom_makan/providers/post_provider.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jom_makan/widgets/custom_buttons.dart';
import 'package:jom_makan/widgets/custom_loading.dart';
import 'package:jom_makan/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class EditPost extends StatefulWidget {
  EditPost();

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController = TextEditingController();
  late TextEditingController _descriptionController = TextEditingController();
  String? selectedActivity;
  XFile? _image;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _titleController = TextEditingController(text: args['currentTitle']);
      _descriptionController =
          TextEditingController(text: args['currentDescription']);

      Provider.of<ParticipationProvider>(context, listen: false)
          .fetchPastParticipatedActivities();
      
      selectedActivity = "${args['activityID']}|${args['activityName']}";
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final participationProvider = Provider.of<ParticipationProvider>(context);
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Create a map of titles and IDs
    List<String> activities = [];
      for (var activity in participationProvider.pastActivities) {
      activities.add("${activity.activityID}|${activity.title}");
    }

    // Create the list of dropdown items
    List<DropdownMenuItem<String>> dropdownItems =
        activities.map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item.split("|")[1]),
                ))
            .toList();

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
                    fontWeight: FontWeight.bold),
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
                        args['postImage'],
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return CustomImageLoading(width: 300);
                          }
                        },
                      )
                    : Image.file(
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        File(_image!.path),
                      ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        getImage();
                      },
                      icon:
                          Icon(Icons.image_outlined, color: AppColors.primary),
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
                      onPressed: () {
                        getImageFromCamera();
                      },
                      icon: Icon(Icons.camera_alt_outlined,
                          color: AppColors.primary),
                      label: Text(
                        'Take A Picture',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10), // Add some space before the separator
                Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                participationProvider.isLoading
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(15, 15, 0, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.event,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Project / Speech Participated',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.placeholder,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                            SpinKitCircle(size: 20, color: AppColors.primary)
                          ],
                        ))
                    : DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: CustomIconText(
                            text: 'Project / Speech Participated',
                            icon: Icons.event,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          items: dropdownItems,
                          value: selectedActivity,
                          onChanged: (value) {
                            setState(() {
                              selectedActivity = value;
                            });
                          },
                        ),
                      ),

                Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                Container(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
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
                Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                Container(
                  height: 200,
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Description here...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.placeholder),
                    maxLines: null, // Makes the TextField multiline
                    expands: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                ),
                Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                SizedBox(height: 10),
                CustomPrimaryButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _updatePost();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please fill out all fields.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    text: "Edit Post")
              ],
            ),
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

  Future getImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  void _updatePost() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String activityID;
  final String activityName;

    if (selectedActivity == null) {
      activityID = args['activityID'];
      activityName = args['activityName'];
    } else {
      activityID = selectedActivity!.split('|')[0];
      activityName = selectedActivity!.split('|')[1];
    }
    await postProvider.updatePost(
        args['postID'],
        _image,
        _titleController.text.trim(),
        _descriptionController.text,
        activityID, activityName);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }
}

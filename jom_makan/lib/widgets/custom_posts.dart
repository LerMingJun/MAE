import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/providers/post_provider.dart';
import 'package:jom_makan/screens/user/community.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_loading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommunityPost extends StatelessWidget {
  final String postID;
  final String? profileImage; // Made nullable to handle potential null cases
  final String? name; // Made nullable to handle potential null cases
  final Timestamp date;
  final String? postImage; // Made nullable to handle potential null cases
  final String? postTitle; // Made nullable to handle potential null cases
  final String? postDescription; // Made nullable to handle potential null cases
  final List<String> likes;
  final List<String> tags;
  final String userID;
  final String? currentUserID;
  final bool? edit;
  final VoidCallback? deletePost;

  const CommunityPost({
    required this.postID,
    this.profileImage,
    this.name,
    required this.tags,
    required this.date,
    this.postImage,
    this.postTitle,
    this.postDescription,
    required this.likes,
    required this.userID,
    required this.currentUserID,
    this.edit = false,
    super.key,
    this.deletePost,
  });

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = date.toDate();
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

    final postProvider = Provider.of<PostProvider>(context);
    final bool isLiked = likes.contains(currentUserID);
    final TextEditingController commentController = TextEditingController();

    // Get the screen width
    final double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2.0), // Border width
                decoration: const BoxDecoration(
                  color: AppColors.primary, // Border color
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      profileImage != null ? NetworkImage(profileImage!) : null,
                  child: profileImage == null ? const Icon(Icons.person) : null,
                ),
              ),
              const SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name ?? 'Unknown User', // Fallback for null name
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  Text(
                    formattedDate, // Fallback for null bio
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.placeholder,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (edit ?? false)
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/editPost',
                      arguments: {
                        'postID': postID,
                        'currentTitle': postTitle,
                        'currentDescription': postDescription,
                        'currentTags': tags,
                        'postImage': postImage,
                      },
                    );
                  },
                  child: Row(
                    children: [
                      if (currentUserID != "admin")
                        const Icon(
                          Icons.edit,
                          color: Colors.blue,
                          size: 20,
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: deletePost,
                        color: Colors.red,
                        tooltip: 'Delete Post',
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              if (postImage != null)
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: Image.network(
                    postImage!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return const CustomImageLoading(width: 250);
                      }
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            postTitle ?? 'No title', // Fallback for null postTitle
            style: GoogleFonts.lato(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            postDescription ??
                'No description available', // Fallback for null postDescription
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.placeholder,
            ),
          ),
          const SizedBox(height: 10),
          // Display tags as a list of chips
          Wrap(
            spacing: 6.0, // Space between tags
            runSpacing: 4.0, // Space between rows if they wrap
            children: tags.map((tag) {
              return Chip(
                label: Text(
                  tag,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                backgroundColor:
                    AppColors.primary, // Customize color as desired
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Distribute the space
            children: [
              // Left side: Display the message with the number of likes
              Text(
                '${likes.length} ${likes.length == 1 ? 'person' : 'people'} like${likes.length == 1 ? 's' : ''} this post!',
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Transform.translate(
                    offset:
                        const Offset(0, 2.5), // Move the count down by 4 pixels
                    child: Text(
                      '${likes.length} ',
                      style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ), // Add some space between the count and the icon
                  InkWell(
                    splashColor: Colors.transparent,
                    child: Icon(
                      isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      color: isLiked ? AppColors.primary : Colors.grey,
                    ),
                    onTap: () {
                      if (isLiked) {
                        postProvider.unlikePost(postID, currentUserID);
                      } else {
                        postProvider.likePost(postID, currentUserID);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

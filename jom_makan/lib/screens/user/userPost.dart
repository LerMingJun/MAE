import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/models/post.dart';
import 'package:jom_makan/providers/post_provider.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_loading.dart';
import 'package:jom_makan/widgets/custom_posts.dart';
import 'package:provider/provider.dart';

class UserPost extends StatefulWidget {
  const UserPost({super.key});

  @override
  State<UserPost> createState() => _UserPostState();
}

class _UserPostState extends State<UserPost> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    //final post = postProvider.userPost;
    final String postID = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: AppColors.background,
                title: const Text('Confirm Delete'),
                content:
                    const Text('Are you sure you want to Delete your Masterpiece?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        await postProvider.deletePost(postID);
                      } catch (e) {
                        print('Error delete post: $e');
                      }

                      Navigator.of(context).pop(true);
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 10,
        shape: const CircleBorder(),
        child: const Icon(Icons.delete),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            Text(userProvider.userData?.username.toUpperCase() ?? '',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.placeholder)),
            Text('Posts',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
          ],
        ),
        backgroundColor: AppColors.background,
      ),
      // body: SafeArea(
      //   child: Padding(
      //     padding: const EdgeInsets.all(20),
      //     child: FutureBuilder<Post?>(
      //       future: postProvider.fetchPostByPostID(postID),
      //       builder: (context, snapshot) {
      //         if (snapshot.connectionState == ConnectionState.waiting) {
      //           return Center(
      //               child: CustomLoading(text: 'Fetching your post...'));
      //         } else if (snapshot.hasError) {
      //           return Center(child: Text('Error: ${snapshot.error}'));
      //         } else if (!snapshot.hasData) {
      //           return Center(child: Text('Post not found'));
      //         } else {
      //           Post post = snapshot.data!;
      //           return CommunityPost(
      //             postID: post.postID,
      //             profileImage: post.user!.profileImage,
      //             name: post.user!.username,
      //             bio: "hihi",
      //             date: post.createdAt,
      //             postImage: post.postImage,
      //             postTitle: post.title,
      //             postDescription: post.description,
      //             activity: post.activityName,
      //             activityID: post.activityID,
      //             likes: post.likes,
      //             userID: userProvider.userData!.userID,
      //             edit: true,
      //           );
      //         }
      //       },
      //     ),
      //   ),
      // ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/models/post.dart';
import 'package:jom_makan/providers/post_provider.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/widgets/custom_posts.dart';
import 'package:jom_makan/widgets/custom_loading.dart';
import 'package:jom_makan/widgets/custom_empty.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  final TextEditingController searchController = TextEditingController();
  List<Post> filteredPosts = [];
  bool showUserPostsOnly = false; // Toggle to filter user-specific posts

  @override
  void initState() {
    super.initState();
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      postProvider.fetchAllPosts().then((_) {
        setState(() {
          filteredPosts = postProvider.posts ?? [];
        });
      });
    });
  }

  void filterPosts(String query) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      if (query.isEmpty) {
        filteredPosts = postProvider.posts ?? [];
      } else {
        filteredPosts = postProvider.posts?.where((post) {
              return (post.title.toLowerCase().contains(query.toLowerCase()) ||
                      post.description
                          .toLowerCase()
                          .contains(query.toLowerCase())) &&
                  (!showUserPostsOnly ||
                      post.userID == userProvider.userData!.userID);
            }).toList() ??
            [];
      }
    });
  }

  void toggleUserPostsFilter() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      showUserPostsOnly = !showUserPostsOnly;
      filteredPosts = postProvider.posts?.where((post) {
            return !showUserPostsOnly ||
                post.userID == userProvider.userData!.userID;
          }).toList() ??
          [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addPost');
        },
        backgroundColor: AppColors.tertiary,
        foregroundColor: Colors.black,
        elevation: 10,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading and Filter Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Community',
                    style: GoogleFonts.lato(
                      fontSize: 24,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      showUserPostsOnly ? Icons.person : Icons.person_outline,
                      color: AppColors.primary,
                    ),
                    onPressed: toggleUserPostsFilter,
                    tooltip: 'Show only my posts',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Search Bar
              TextField(
                controller: searchController,
                onChanged: filterPosts,
                decoration: InputDecoration(
                  hintText: 'Search posts...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  suffixIcon: const Icon(Icons.search, color: Colors.blue),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                ),
              ),
              const SizedBox(height: 10),
              // Post Content
              if (postProvider.isLoading)
                const Expanded(
                  child: Center(
                    child: CustomLoading(text: 'Fetching interesting Posts!'),
                  ),
                )
              else if (filteredPosts.isEmpty)
                const Expanded(
                  child: EmptyWidget(
                    text: 'No Posts Found.\nPlease Try Again.',
                    image: 'assets/no-filter.png',
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await postProvider.fetchAllPosts();
                      setState(() {
                        filteredPosts = postProvider.posts ?? [];
                      });
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80.0),
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = postProvider.posts![index];
                        final isEditable =
                            post.userID == userProvider.userData!.userID;
                        return CommunityPost(
                          postID: post.postId,
                          profileImage:
                              'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
                          name: post.user!.username,
                          tags: post.tags,
                          date: post.createdAt,
                          postImage: post.postImage,
                          postTitle: post.title,
                          postDescription: post.description,
                          likes: post.likes,
                          userID: userProvider.userData!.userID,
                          edit: isEditable,
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

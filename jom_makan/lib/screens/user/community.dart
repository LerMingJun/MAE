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

  @override
  void initState() {
    super.initState();
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    // Fetch posts when the page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      postProvider.fetchAllPosts().then((_) {
        setState(() {
          filteredPosts =
              postProvider.posts ?? []; // Initialize filteredPosts here
        });
      });
    });
  }

  void filterPosts(String query) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    if (query.isEmpty) {
      setState(() {
        filteredPosts = postProvider.posts ?? []; // Reset to all posts
      });
    } else {
      setState(() {
        filteredPosts = postProvider.posts?.where((post) {
              return post.title.toLowerCase().contains(query.toLowerCase()) ||
                  post.description.toLowerCase().contains(query.toLowerCase());
            }).toList() ??
            [];
      });
    }
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
        shape: CircleBorder(),
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Community',
                          style: GoogleFonts.lato(
                              fontSize: 24,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Search Bar
              TextField(
                controller: searchController,
                onChanged: filterPosts,
                decoration: InputDecoration(
                  hintText: 'Search posts...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  suffixIcon: Icon(Icons.search, color: Colors.blue),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),
              SizedBox(height: 10),
              // Post Content
              if (postProvider.isLoading)
                Expanded(
                  child: Center(
                    child: CustomLoading(text: 'Fetching interesting Posts!'),
                  ),
                )
              else if (filteredPosts.isEmpty)
                Expanded(
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
                        filteredPosts =
                            postProvider.posts ?? []; // Reset after refresh
                      });
                    },
                    child: ListView.builder(
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index];
                        final isEditable = post.userID == userProvider.userData!.userID;
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

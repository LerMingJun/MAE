import 'package:flutter/material.dart';
import 'package:jom_makan/constants/placeholderURL.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/screens/user/addPost.dart';
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
  final String? userId;
  final String? userRole;
  const Community({super.key, required this.userId, required this.userRole});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  final TextEditingController searchController = TextEditingController();
  List<Post> filteredPosts = [];
  bool showUserPostsOnly = false;
  bool isDescending = true;

  String? userId;
  String? userRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPosts();
      if (widget.userId == null && widget.userRole == "user") {
        // Fetch user data asynchronously and update state
        _fetchUserData();
      } else {
        // If userId and userRole are provided, use them directly
        userId = widget.userId;
        userRole = widget.userRole;
      }
    });
  }

  Future<void> _fetchUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchUserData();

    setState(() {
      userId = userProvider.userData?.userID;
      userRole = "user";
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    filteredPosts = postProvider.posts ?? [];
    sortPosts();
  }

  void _fetchPosts() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    await postProvider.fetchAllPosts();
    setState(() {
      filteredPosts = postProvider.posts ?? [];
      sortPosts();
    });
  }

  void filterPosts(String query) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    setState(() {
      if (query.isEmpty) {
        filteredPosts = postProvider.posts ?? [];
      } else {
        print("User ID from filter: $userId");
        filteredPosts = postProvider.posts?.where((post) {
              return (post.title.toLowerCase().contains(query.toLowerCase()) ||
                      post.description
                          .toLowerCase()
                          .contains(query.toLowerCase())) &&
                  (!showUserPostsOnly || post.userID == userId);
            }).toList() ??
            [];
      }
      sortPosts();
    });
  }

  void toggleUserPostsFilter() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    setState(() {
      showUserPostsOnly = !showUserPostsOnly;
      filteredPosts = postProvider.posts?.where((post) {
            return !showUserPostsOnly || post.userID == userId;
          }).toList() ??
          [];
      sortPosts();
    });
  }

  void toggleSortOrder() {
    setState(() {
      isDescending = !isDescending;
      sortPosts();
    });
  }

  void sortPosts() {
    setState(() {
      filteredPosts.sort((a, b) {
        final aTime = a.createdAt;
        final bTime = b.createdAt;
        if (aTime == null || bTime == null) {
          return 0;
        }
        return isDescending ? bTime.compareTo(aTime) : aTime.compareTo(bTime);
      });
    });
  }

  void deletePost(String postId) async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await postProvider.deletePost(postId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully')),
      );
      setState(() {
        filteredPosts.removeWhere((post) => post.postId == postId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddPost(
                        userId: widget.userId,
                        userRole: widget.userRole,
                      )));
        },
        backgroundColor: AppColors.tertiary,
        foregroundColor: Colors.black,
        elevation: 10,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: widget.userRole == "restaurant" || widget.userRole == "admin"
            ? BackButton(
                // color: AppColors.primary, // Set the color of the back icon
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : null,
        title: Text(
          'Community',
          style: GoogleFonts.lato(
            fontSize: 24,
            color: widget.userRole == "restaurant" || widget.userRole == "admin"
                ? Colors.black
                : AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              showUserPostsOnly ? Icons.person : Icons.person_outline,
              color:
                  widget.userRole == "restaurant" || widget.userRole == "admin"
                      ? Colors.black
                      : AppColors.primary,
            ),
            onPressed: toggleUserPostsFilter,
            tooltip: 'Show only my posts',
          ),
          IconButton(
            icon: Icon(
              isDescending ? Icons.arrow_downward : Icons.arrow_upward,
              color:
                  widget.userRole == "restaurant" || widget.userRole == "admin"
                      ? Colors.black
                      : AppColors.primary,
            ),
            onPressed: toggleSortOrder,
            tooltip: isDescending ? 'Sort Ascending' : 'Sort Descending',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
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
                        sortPosts();
                      });
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80.0),
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index];

                        final isEditable = userId == post.userID;
                        return CommunityPost(
                          postID: post.postId,
                          profileImage: post.user?.profileImage ??
                              post.restaurant?.image ??
                              userPlaceholder,
                          name: post.user?.username ??
                              post.restaurant?.name ??
                              '',
                          tags: post.tags,
                          date: post.createdAt,
                          postImage: post.postImage,
                          postTitle: post.title,
                          postDescription: post.description,
                          likes: post.likes,
                          userID: post.userID,
                          edit: isEditable,
                          deletePost:
                              isEditable ? () => deletePost(post.postId) : null,
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

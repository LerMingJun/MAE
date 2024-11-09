import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/constants/placeholderURL.dart';
import 'package:jom_makan/providers/auth_provider.dart';
import 'package:jom_makan/providers/post_provider.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_empty.dart';
import 'package:jom_makan/widgets/custom_loading.dart';
import 'package:jom_makan/widgets/custom_text.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchUserData();
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      postProvider.fetchAllPostsByUserID();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.read<AuthProvider>().signOut();
          if (context.read<AuthProvider>().user == null) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 5,
        shape: const CircleBorder(),
        child: const Icon(Icons.logout_outlined),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You Yourself,',
                          style: GoogleFonts.lato(fontSize: 17),
                        ),
                        Row(
                          children: [
                            Text(
                              userProvider.userData?.fullName ?? "",
                              style: GoogleFonts.lato(
                                  fontSize: 25, color: AppColors.primary),
                            ),
                            IconButton(
                              highlightColor: Colors.transparent,
                              onPressed: () {
                                Navigator.pushNamed(context, '/editProfile');
                              },
                              icon: const Icon(Icons.mode_edit_outlined),
                              iconSize: 25,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(2.0), // Border width
                      decoration: const BoxDecoration(
                        color: AppColors.primary, // Border color
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                            userProvider.userData?.profileImage ??
                                userPlaceholder),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 7,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: AppColors.tertiary,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.park_outlined,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'My Proudly Stats',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            //IconButton(onPressed: _handleRefresh, icon: Icon(Icons.refresh)),
                            InkWell(
                              onTap: _handleRefresh,
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              splashColor: AppColors.secondary,
                              child: const Icon(Icons.autorenew),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // CustomNumberText(
                            //     number: '${userProvider.userData?.impoints ?? 0}',
                            //     text: 'Impoints'),
                            CustomNumberText(
                                number: '${userProvider.postCount ?? 0}',
                                text: 'Posts'),
                            CustomNumberText(
                                number: '${userProvider.likeCount ?? 0}',
                                text: 'Likes'),
                            CustomNumberText(
                                number: '${userProvider.participationCount ?? 0}',
                                text: 'Participations'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 38.0,
                  child: TabBar(
                    splashFactory: NoSplash.splashFactory,
                    dividerColor: Colors.transparent,
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    labelStyle: GoogleFonts.poppins(),
                    unselectedLabelStyle: GoogleFonts.poppins(),
                    tabs: [
                      Tab(
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: const Text('Posts'),
                        ),
                      ),
                      Tab(
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: const Text('History'),
                        ),
                      ),
                    ],
                  ),
                ),
                 SizedBox(
                  width: double.infinity,
                  height: 500,
                   child: TabBarView(
                      controller: _tabController,
                      children: const [
                        PostContent(),
                        HistoryContent(),
                      ],
                    ),
                 ),
                
              ],
            ),
          ),
        ),
      ),

      //),
    );
  }
}

class PostContent extends StatelessWidget {
  const PostContent({super.key});

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    if (postProvider.isLoading) {
      return const Center(child: CustomLoading(text: "Fetching Posts..."));
    } else if (postProvider.postsByUserID?.isEmpty ?? false) {
      return const EmptyWidget(
          text:
              'No Posts Added Yet.\nLooking forward for your first post in Folks!',
          image: 'assets/no-post.png');
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: GridView.builder(
          padding: const EdgeInsets.all(4.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 images per row
            crossAxisSpacing: 7.0, // Horizontal spacing between images
            mainAxisSpacing: 7.0, // Vertical spacing between images
          ),
          itemCount: postProvider.postsByUserID?.length ?? 0,
          itemBuilder: (context, index) {
            final post = postProvider.postsByUserID![index];
            return null;
            // return InkWell(
            //   onTap: () {
            //     Navigator.pushNamed(context, '/userPost',
            //         arguments: post.postID);
            //   },
            //   // child: Ink.image(
            //   //   fit: BoxFit.cover,
            //   //   image: NetworkImage(post.postImage),
            //   // ),
            //   child: Image.network(
            //     post.postImage,
            //     fit: BoxFit.cover,
            //     loadingBuilder: (context, child, loadingProgress) {
            //       if (loadingProgress == null) {
            //         return child;
            //       } else {
            //         return CustomImageLoading(width: 30);
            //       }
            //     },
            //   ),
            // );
            // );
          },
        ),
      );
    }
  }
}

class HistoryContent extends StatelessWidget {
  const HistoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.isHistoryLoading ?? false) {
      return const Center(child: CustomLoading(text: "Fetching History..."));
    } else if (userProvider.history?.isEmpty ?? false) {
      return const EmptyWidget(
          text:
              'Oops! Looks like you have not participated in any activities yet.',
          image: 'assets/oops.png');
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 15),
          scrollDirection: Axis.vertical,
          itemCount: userProvider.history?.length ?? 0,
          itemBuilder: (context, index) {
            final history = userProvider.history![index];

            DateTime date = history.hostDate.toDate();
            String formattedDate =
                DateFormat('dd MMMM yyyy, HH:mm').format(date);
            return Card(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: 80,
                child: Row(
                  children: [
                     Image.network(
                        history.image,
                        width:100,
                        height: 70,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return const CustomImageLoading(width: 100);
                          }
                        },
                      ),
                    

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              history.title,
                              style: GoogleFonts.lato(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "** You participated this activity on $formattedDate!",
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: AppColors.placeholder),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  }
}

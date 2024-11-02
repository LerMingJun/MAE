import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:folks_app/constants/placeholderURL.dart';
import 'package:folks_app/providers/auth_provider.dart';
import 'package:folks_app/providers/post_provider.dart';
import 'package:folks_app/providers/user_provider.dart';
import 'package:folks_app/theming/custom_themes.dart';
import 'package:folks_app/widgets/custom_empty.dart';
import 'package:folks_app/widgets/custom_loading.dart';
import 'package:folks_app/widgets/custom_text.dart';
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
        shape: CircleBorder(),
        child: Icon(Icons.logout_outlined),
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
                              icon: Icon(Icons.mode_edit_outlined),
                              iconSize: 25,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(2.0), // Border width
                      decoration: BoxDecoration(
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
                SizedBox(height: 10),
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
                            Icon(
                              Icons.park_outlined,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'My Proudly Stats',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            //IconButton(onPressed: _handleRefresh, icon: Icon(Icons.refresh)),
                            InkWell(
                              onTap: _handleRefresh,
                              child: Icon(Icons.autorenew),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              splashColor: AppColors.secondary,
                            )
                          ],
                        ),
                        SizedBox(height: 16),
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
                SizedBox(height: 20),
                Container(
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
                          child: Text('Posts'),
                        ),
                      ),
                      Tab(
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text('History'),
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
                      children: [
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
  PostContent({super.key});

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    if (postProvider.isLoading) {
      return Center(child: CustomLoading(text: "Fetching Posts..."));
    } else if (postProvider.postsByUserID?.isEmpty ?? false) {
      return EmptyWidget(
          text:
              'No Posts Added Yet.\nLooking forward for your first post in Folks!',
          image: 'assets/no-post.png');
    } else {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: GridView.builder(
          padding: EdgeInsets.all(4.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 images per row
            crossAxisSpacing: 7.0, // Horizontal spacing between images
            mainAxisSpacing: 7.0, // Vertical spacing between images
          ),
          itemCount: postProvider.postsByUserID?.length ?? 0,
          itemBuilder: (context, index) {
            final post = postProvider.postsByUserID![index];
            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/userPost',
                    arguments: post.postID);
              },
              // child: Ink.image(
              //   fit: BoxFit.cover,
              //   image: NetworkImage(post.postImage),
              // ),
              child: Image.network(
                post.postImage,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return CustomImageLoading(width: 30);
                  }
                },
              ),
            );
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
      return Center(child: CustomLoading(text: "Fetching History..."));
    } else if (userProvider.history?.isEmpty ?? false) {
      return EmptyWidget(
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
              margin: EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
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
                            return CustomImageLoading(width: 100);
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
                            SizedBox(height: 5),
                            Text(
                              "** You participated this activity on ${formattedDate}!",
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

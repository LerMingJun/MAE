import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/constants/placeholderURL.dart';
import 'package:jom_makan/models/complain.dart';
import 'package:jom_makan/providers/auth_provider.dart';
import 'package:jom_makan/providers/complain_provider.dart';
import 'package:jom_makan/providers/helpitem_provider.dart';
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
                              Icons.visibility,
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
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
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
                                number: '${userProvider.bookingCount ?? 0}',
                                text: 'Bookings'),
                            CustomNumberText(
                                number: '${userProvider.reviewCount ?? 0}',
                                text: 'Reviews'),
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
                          child: const Text('Faqs'),
                        ),
                      ),
                      Tab(
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: const Text('Complains'),
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
                      FaqContent(),
                      Complains(),
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

class FaqContent extends StatefulWidget {
  const FaqContent({super.key});

  @override
  _FaqContentState createState() => _FaqContentState();
}

class _FaqContentState extends State<FaqContent> {
  // Store the index of the selected FAQ to toggle the subtitle visibility
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<HelpItemProvider>(context, listen: false).fetchAllHelpItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HelpItemProvider>(
      builder: (context, helpItemProvider, _) {
        final helpItems = helpItemProvider.helpItems;

        if (helpItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: helpItems.length,
          itemBuilder: (context, index) {
            final item = helpItems[index];

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  setState(() {
                    // Toggle subtitle visibility
                    _expandedIndex = _expandedIndex == index ? null : index;
                  });
                },
                subtitle: _expandedIndex == index
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          item.subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}

class Complains extends StatefulWidget {
  const Complains({super.key});

  @override
  State<Complains> createState() => _ComplainsState();
}

class _ComplainsState extends State<Complains> {
  final _complainController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Schedule the data fetch to be called after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      Provider.of<ComplainProvider>(context, listen: false)
          .fetchComplainByUserId(userProvider.userData!.userID);
    });
  }

  Future<void> _showCreateComplainDialog(BuildContext context) async {
    final complainProvider =
        Provider.of<ComplainProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String userID = userProvider.userData!.userID;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Create a Complaint"),
          content: TextField(
            controller: _complainController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Enter your complaint",
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () async {
                if (_complainController.text.isNotEmpty) {
                  Complain newComplain = Complain(
                    id: '',
                    userID: userID,
                    userType: "user",
                    description: _complainController.text,
                    feedback: '',
                  );

                  await context
                      .read<ComplainProvider>()
                      .addComplain(newComplain);
                  Navigator.of(context).pop();
                  _complainController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Complaint Sent!'),
                      // backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Consumer<ComplainProvider>(
              builder: (context, provider, child) {
                final complains = provider.userComplains;

                if (complains.isEmpty) {
                  return const Center(
                    child: EmptyWidget(
                      text: "No Complaints Found.",
                      image: 'assets/projectEmpty.png',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: complains.length,
                  itemBuilder: (context, index) {
                    final complain = complains[index];
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: ExpansionTile(
                        title: Text(
                          complain.description ?? 'No description available.',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              complain.feedback.isNotEmpty
                                  ? complain.feedback
                                  : 'No feedback available.',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _showCreateComplainDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              child: const Text(
                'Create Complaint',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

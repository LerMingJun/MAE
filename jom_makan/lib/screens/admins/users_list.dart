import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/models/user.dart';
import 'package:jom_makan/providers/user_provider.dart';
// import 'package:jom_makan/screens/admins/user_details_screen.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_empty.dart';
import 'package:jom_makan/widgets/custom_loading.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String searchText = '';

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userProvider.fetchAllUsers();
    });
  }

  void _searchUsers(String text) {
    setState(() {
      searchText = text;
    });
    Provider.of<UserProvider>(context, listen: false).searchUsers(text);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
        child: RefreshIndicator(
          onRefresh: () async {
            await userProvider.fetchAllUsers();
          },
          edgeOffset: 100,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Text(
                            'All Users',
                            style: GoogleFonts.lato(
                              fontSize: 24,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Optional: Add filter functionality
                            },
                            icon: const Icon(Icons.filter_list),
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 40),
                          child: TextField(
                            onChanged: (text) {
                              _searchUsers(text);
                            },
                            decoration: InputDecoration(
                              hintText: 'Search Users',
                              hintStyle: GoogleFonts.poppins(fontSize: 12),
                              suffixIcon: const Icon(Icons.search, size: 20),
                              filled: true,
                              isDense: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 8.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                expandedHeight: 130,
              ),
              if (userProvider.isLoading)
                const SliverFillRemaining(
                  child: CustomLoading(text: 'Fetching Users...'),
                )
              else if (userProvider.users.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: EmptyWidget(
                      text: "No Users Found.\nPlease try again.",
                      image: 'assets/projectEmpty.png',
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      User user = userProvider.users[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: GestureDetector(
                          onTap: () {
                          //   // Navigate directly to UserDetailsScreen
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => UserDetailsScreen(
                          //           user: user), // Pass the user object here
                          //     ),
                          //   );
                          },
                          child: CustomUserCard(user: user),
                        ),
                      );
                    },
                    childCount: userProvider.users.length,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// class User {
//   final DateTime createdAt;
//   final String email;
//   final String fullName;
//   final int impoints;
//   final String introduction;
//   final String profileImage;
//   final String signinMethod;
//   final String userID;
//   final String username;

//   User({
//     required this.createdAt,
//     required this.email,
//     required this.fullName,
//     required this.impoints,
//     required this.introduction,
//     required this.profileImage,
//     required this.signinMethod,
//     required this.userID,
//     required this.username,
//   });
// }

class CustomUserCard extends StatelessWidget {
  final User user;

  const CustomUserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Format the createdAt date
    final formattedDate = DateFormat('dd MMMM yyyy').format(user.createdAt.toDate());

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image section
            CircleAvatar(
              radius: 30,
              backgroundImage: user.profileImage.isNotEmpty
                  ? NetworkImage(user.profileImage)
                  : const AssetImage('assets/placeholder.png') as ImageProvider,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(width: 16), // Spacing between image and text
            // User info section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Joined on: $formattedDate',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
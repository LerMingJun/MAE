import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jom_makan/models/user.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/screens/admins/user_detail.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_empty.dart';
import 'package:jom_makan/widgets/custom_loading.dart';
import 'package:provider/provider.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userProvider
          .fetchAllUsers(); // Fetch all users when the page is initialized
    });
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String searchText = '';

  void _searchUsers(String text) {
    setState(() {
      searchText = text;
    });
    Provider.of<UserProvider>(context, listen: false).searchUsers(text);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    final activeUsers =
        userProvider.users.where((user) => user.status == 'Active').toList();
    final inactiveUsers =
        userProvider.users.where((user) => user.status != 'Active').toList();

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
                            'Manage Users',
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
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 40),
                        child: TextField(
                          onChanged: (text) {
                            _searchUsers(text);
                          },
                          onTapOutside: (event) {
                            FocusScope.of(context).unfocus();
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
                    ],
                  ),
                ),
                expandedHeight: 130,
                pinned: true,
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Active'),
                    Tab(text: 'Inactive'),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUserList(activeUsers, userProvider.isLoading),
                    _buildUserList(inactiveUsers, userProvider.isLoading),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(List<User> users, bool isLoading) {
    if (isLoading) {
      return const Center(child: CustomLoading(text: 'Fetching Users...'));
    } else if (users.isEmpty) {
      return const Center(
        child: EmptyWidget(
          text: "No Users Found.\nPlease try again.",
          image: 'assets/projectEmpty.png',
        ),
      );
    } else {
      return ListView.builder(
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          User user = users[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserDetailsScreen(
                      user: user,
                    ),
                  ),
                );
              },
              child: CustomUserCard(
                profileImage: user.profileImage,
                fullName: user.fullName,
                username: user.username,
                email: user.email,
                dietaryPreferences: user.dietaryPreferences,
                createdAt: user.createdAt.toDate(),
                userID: user.userID,
                status: user.status,
                commentByAdmin: user.commentByAdmin,
              ),
            ),
          );
        },
      );
    }
  }
}

class CustomUserCard extends StatelessWidget {
  final String profileImage;
  final String fullName;
  final String username;
  final String email;
  final List<String> dietaryPreferences;
  final DateTime createdAt;
  final String userID; // Include userID if needed
  final String status;
  final String commentByAdmin;

  const CustomUserCard({
    required this.profileImage,
    required this.fullName,
    required this.username,
    required this.email,
    required this.dietaryPreferences,
    required this.createdAt,
    required this.userID,
    required this.status,
    required this.commentByAdmin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailsScreen(
              user: User(
                userID: userID,
                fullName: fullName,
                username: username,
                email: email,
                profileImage: profileImage,
                dietaryPreferences: dietaryPreferences,
                createdAt: Timestamp.fromDate(createdAt),
                status: status,
                commentByAdmin: commentByAdmin,
              ),
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Image.network(
                profileImage,
                height: 120,
                width: 100,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 100);
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@$username',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dietaryPreferences.join(', '),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created at: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt)}',
                      style: GoogleFonts.lato(
                        fontSize: 10,
                        color: Colors.black45,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status == 'Delete'
                          ? 'Deleted'
                          : (status == 'Suspend'
                              ? 'Suspended'
                              : 'Active'),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: status == 'Delete'
                            ? Colors.red
                            : (status == 'Suspend'
                                ? Colors.orange
                                : Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/screens/mainpage.dart
import 'package:flutter/material.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/screens/admins/complain.dart';
import 'package:jom_makan/screens/admins/edit_store_detail.dart';
import 'package:jom_makan/screens/admins/overall_analytics.dart';
import 'package:jom_makan/screens/admins/restaurant_list.dart';
import 'package:jom_makan/screens/admins/users_list.dart';
import 'package:jom_makan/widgets/admins/custom_bottom_navigation.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<RestaurantProvider>(context, listen: false)
          .fetchAllRestaurants();
      Provider.of<RestaurantProvider>(context, listen: false)
          .fetchUnapprovedRestaurants();
      Provider.of<UserProvider>(context, listen: false).fetchAllUsers();
    });
  }

  int _selectedIndex = 0;
  int _currentCarouselIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final List<Map<String, String>> pendingApprovals = [
      {
        "title":
            "Restaurant Pending Approval (${restaurantProvider.unapprovedRestaurantCount})",
        "subtitle": "Please check the application status.",
        "time": "Submitted: 2 days ago",
        "status": "Approval required"
      },
      {
        "title": "New Restaurant Application",
        "subtitle": "Check for initial review.",
        "time": "Submitted: 3 days ago",
        "status": "Initial review required"
      },
      {
        "title": "Re-approval Needed",
        "subtitle": "Previous issues resolved.",
        "time": "Submitted: 5 days ago",
        "status": "Final review pending"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Add this line
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          children: [
            Image.asset('assets/logo.jpg', width: 50, height: 50),
            const SizedBox(width: 8),
            const Text(
              'JomMakan',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Notification action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Highlights Section
            const Text(
              'Today\'s Highlights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Carousel Section
            SizedBox(
              height: 130,
              child: PageView.builder(
                itemCount: pendingApprovals.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentCarouselIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildCarouselCard(pendingApprovals[index]);
                },
              ),
            ),

            // Carousel Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pendingApprovals.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentCarouselIndex == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentCarouselIndex == index
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Grid Section
            GridView(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                children: [
                  InkWell(
                    onTap: () {
                      Future.delayed(const Duration(milliseconds: 200), () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ComplainsPage()),
                        );
                      });
                    },
                    splashColor: Colors.grey.withOpacity(0.5),
                    child: _buildGridItem(Icons.report_problem, 'Complain'),
                  ),
                  InkWell(
                    onTap: () {
                      Future.delayed(const Duration(milliseconds: 200), () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const OverallAnalyticsScreen()),
                        );
                      });
                    },
                    splashColor: Colors.grey.withOpacity(0.5),
                    child: _buildGridItem(Icons.analytics, 'Analytics'),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RestaurantsPage()),
                      );
                    },
                    child: _buildGridItem(Icons.restaurant, 'Restaurant'),
                  ),
                  _buildGridItem(Icons.group, 'Community'),
                                    InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UsersPage()),
                      );
                    },
                    child: _buildGridItem(Icons.person, 'User'),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StoreDetailsPage()),
                      );
                    },
                    child: _buildGridItem(Icons.info, 'Info'),
                  ),
                  _buildGridItem(Icons.local_offer, 'Promotion'),
                ]),
            const SizedBox(height: 30),

            // Current Users and Restaurant/Partner Section
            const Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      "System Users",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildInfoCard(
                  icon: Icons.people,
                  label: 'Customers',
                  count: userProvider.totalUserCount,
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildInfoCard(
                  icon: Icons.store,
                  label: 'Partners',
                  count: restaurantProvider.totalRestaurantCount,
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }

  // Helper method to build each grid item
  Widget _buildGridItem(IconData icon, String label) {
    return Container(
      width: 60,
      height: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Helper method to build a carousel card
  Widget _buildCarouselCard(Map<String, String> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              const Icon(Icons.pending, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                data['title']!,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            data['subtitle']!,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.black54, size: 16),
              const SizedBox(width: 4),
              Text(data['time']!,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(width: 16),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StoreDetailsPage()),
                  );
                },
                child: const Icon(Icons.info_outline,
                    color: Colors.black54, size: 16),
              ),
              const SizedBox(width: 4),
              Text(data['status']!,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build the info cards
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

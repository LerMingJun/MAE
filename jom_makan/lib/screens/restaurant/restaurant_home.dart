// lib/screens/restaurant/restaurant_home.dart
import 'package:flutter/material.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/screens/restaurant/voucher_page.dart';
import 'package:provider/provider.dart';
import 'package:jom_makan/widgets/restaurant/custom_bottom_navigation.dart';

class RestaurantHome extends StatefulWidget {
  const RestaurantHome({super.key});

  @override
  _RestaurantHomeState createState() => _RestaurantHomeState();
}

class _RestaurantHomeState extends State<RestaurantHome> {
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

    final List<Map<String, String>> pendingApprovals = [
      {
        "title":
            "New Orders Pending Approval (${restaurantProvider.unapprovedRestaurantCount})",
        "subtitle": "Check and process new orders.",
        "time": "Received: 1 day ago",
        "status": "Approval required"
      },
      {
        "title": "Updated Menu Review",
        "subtitle": "Review recent menu changes.",
        "time": "Updated: 2 days ago",
        "status": "Review required"
      },
      {
        "title": "Feedback from Customers",
        "subtitle": "Respond to feedback.",
        "time": "Received: 3 days ago",
        "status": "Response needed"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          children: [
            Image.asset('assets/logo.jpg', width: 50, height: 50),
            const SizedBox(width: 8),
            const Text(
              'JOM MAKAN',
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
                  _buildGridItem(Icons.receipt, 'Orders'),
                  _buildGridItem(Icons.menu_book, 'Menu'),
                  _buildGridItem(Icons.feedback, 'Feedback'),
                  InkWell(
                    onTap: () {
                      Future.delayed(const Duration(milliseconds: 200), () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const VoucherScreen()),
                        );
                      });
                    },
                    child: _buildGridItem(Icons.local_offer, 'Promotions'),
                  ),
                  _buildGridItem(Icons.report, 'Reports'),
                  _buildGridItem(Icons.insights, 'Analytics'),
                  _buildGridItem(Icons.group, 'Community'),
                  // _buildGridItem(Icons.info, 'Info'),
                ]),
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
    return SizedBox(
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
              const Icon(Icons.info_outline, color: Colors.black54, size: 16),
              const SizedBox(width: 4),
              Text(data['status']!,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }
}

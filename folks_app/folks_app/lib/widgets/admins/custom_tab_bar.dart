import 'package:flutter/material.dart';
import 'package:folks_app/screens/admins/customer_analytics.dart';
import 'package:folks_app/screens/admins/overall_analytics.dart';
import 'package:folks_app/screens/admins/partner_analytics.dart';

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({super.key, required this.index});
  final int index;

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 3, vsync: this, initialIndex: widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.green, // Active tab color
            unselectedLabelColor: Colors.black, // Inactive tab color
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(color: Colors.green, width: 2.0),
            ),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Partner'),
              Tab(text: 'Customer'),
            ],
            onTap: (index) {
              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OverallAnalyticsScreen()),
                );
              } else if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PartnerAnalyticsScreen()),
                );
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CustomerAnalyticsScreen()),
                );
              }
            },
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildPartnerTab(),
              _buildCustomersTab(),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _buildOverviewTab() {
  return const Center(child: Text('Overview Content'));
}

Widget _buildPartnerTab() {
  return const Center(child: Text('Sales Content'));
}

Widget _buildCustomersTab() {
  return const Center(child: Text('Customers Content'));
}

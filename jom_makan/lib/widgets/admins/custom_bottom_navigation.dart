// lib/widget/custom_bottom_navigation.dart
import 'package:flutter/material.dart';
import 'package:jom_makan/screens/admins/edit_store_detail.dart';
import 'package:jom_makan/screens/admins/mainpage.dart';
import 'package:jom_makan/screens/admins/overall_analytics.dart';
import 'package:jom_makan/screens/admins/setting.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const CustomBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        if (index == 0) {
          // Navigate to MainPage when home icon is tapped
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else if (index == 1) {
          // Navigate to Settings when the last icon is tapped
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StoreDetailsPage()),
          );
          } else if (index == 2) {
          // Navigate to Settings when the last icon is tapped
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OverallAnalyticsScreen()),
          );} else if (index == 3) {
          // Navigate to Settings when the last icon is tapped
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StoreProfilePage()),
          );
        } else {
          // Call the original onItemSelected callback for other icons
          onItemSelected(index);
        }
      },
      backgroundColor: Colors.grey[200],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.edit),
          label: '',
        ),
       BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: '',
        ),
      BottomNavigationBarItem(
        icon: Icon(Icons.more_horiz),
        label: '',
      ),
      ],
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    );
  }
}

// lib/widget/custom_bottom_navigation.dart
import 'package:flutter/material.dart';
import 'package:jom_makan/screens/restaurant/restaurant_home.dart'; // Home screen
// import 'package:jom_makan/screens/restaurant/booking.dart'; // Booking screen
// import 'package:jom_makan/screens/restaurant/voucher.dart'; // Voucher screen
// import 'package:jom_makan/screens/restaurant/community.dart'; // Community screen
// import 'package:jom_makan/screens/restaurant/profile.dart'; // Profile screen

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
          // Navigate to Home page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RestaurantHome()),
          );
        } else if (index == 1) {
          // Navigate to Booking page
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const BookingPage()),
          // );
        } else if (index == 2) {
          // Navigate to Voucher page
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const VoucherPage()),
          // );
        } else if (index == 3) {
          // Navigate to Community page
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const CommunityPage()),
          // );
        } else if (index == 4) {
          // Navigate to Profile page
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const ProfilePage()),
          // );
        } else {
          // Call the original onItemSelected callback for other icons
          onItemSelected(index);
        }
      },
      backgroundColor: Colors.grey[200],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          label: 'Booking',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_offer),
          label: 'Voucher',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Community',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    );
  }
}

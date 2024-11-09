import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jom_makan/providers/store_provider.dart';
import 'package:jom_makan/screens/admins/edit_store_detail.dart';
import 'package:jom_makan/screens/admins/helpcenter.dart';
import 'package:jom_makan/screens/admins/overall_analytics.dart';
import 'package:jom_makan/screens/admins/restaurant_list.dart';
import 'package:jom_makan/screens/admins/users_list.dart';
import 'package:jom_makan/widgets/restaurant/custom_bottom_navigation.dart';
import 'package:provider/provider.dart';

class RestaurantSetting extends StatefulWidget {
  final String restaurantId;
  const RestaurantSetting({super.key, required this.restaurantId});
  @override
  _RestaurantSettingState createState() => _RestaurantSettingState();
}

class _RestaurantSettingState extends State<RestaurantSetting> {
  int _selectedIndex = 3; // Start with "More" tab highlighted
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<StoreProvider>(context, listen: false).fetchStore();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation logic here based on the index
  }

  String formatPhoneNumber(String number) {
    if (number.length <= 2) return number;
    if (number.length <= 5) {
      return '${number.substring(0, 2)} ${number.substring(2)}';
    }
    return '${number.substring(0, 2)} ${number.substring(2, 6)} ${number.substring(6)}';
  }

  void _showContactAdminOverlay(int pinNumber) {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display PIN number
              Text(
                'PIN #$pinNumber',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // JomMakan Contact Information title
              const Text(
                "JomMakan Contact Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                "For any inquiries, please reach out using the contact details below.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),

              // Phone number or Not Available
              if (storeProvider.storeNumber != null)
                Text(
                  formatPhoneNumber(storeProvider.storeNumber ?? ''),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                )
              else
                const Text(
                  'Not Available',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 8),

              // Email or Not Available
              Text(
                storeProvider.storeEmail ?? 'Not Available',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),

              // Close button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the overlay
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false, // This line disables the back button
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Column(
            children: [
              Image.asset(
                'assets/logo.jpg',
                height: 100,
              ),
              const SizedBox(height: 16),
              const Text(
                'Jom Makan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Text('Your Favorite Food Discovery App'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StoreDetailsPage()),
                  );
                },
                child: const Text('View and edit store profile'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _buildIconButton(
                Icons.people,
                'Partners',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const RestaurantsPage()), // Navigate to InsightsPage instead
                  );
                },
              ),
              _buildIconButton(
                Icons.supervised_user_circle,
                'Users',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const UsersPage()), // Navigate to InsightsPage instead
                  );
                },
              ),
              _buildIconButton(
                Icons.show_chart,
                'Insights',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const OverallAnalyticsScreen()), // Navigate to InsightsPage instead
                  );
                },
              ),
            ],
          ),
          const Divider(height: 40),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('FAQ'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HelpCenterScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_support_outlined),
            title: const Text('Contact Admin'),
            onTap: () {
              final int pinNumber = _generateRandomPin();
              _showContactAdminOverlay(pinNumber);
            },
          ),
          const Divider(height: 40),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Personal profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const StoreDetailsPage()),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
        restaurantId: widget.restaurantId,
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  int _generateRandomPin() {
    return Random().nextInt(999999); // generates a random 6-digit number
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:folks_app/screens/admins/edit_store_detail.dart';
import 'package:folks_app/screens/admins/overall_analytics.dart';
import 'package:folks_app/widgets/admins/custom_bottom_navigation.dart';

class StoreProfilePage extends StatefulWidget {
  const StoreProfilePage({super.key});

  @override
  _StoreProfilePageState createState() => _StoreProfilePageState();
}

class _StoreProfilePageState extends State<StoreProfilePage> {
  int _selectedIndex = 3; // Start with "More" tab highlighted

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation logic here based on the index
  }

  void _showContactTechnicianOverlay(int pinNumber) {
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
              Text(
                'PIN #$pinNumber',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 16),
              Text(
                "If your device can’t call out, dial this number using a phone. Enter the PIN above when asked as it helps to identify you.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              const Text(
                "03 2788 1333",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "technician@example.com",
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
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

  void _showStoreContactOverlay() {
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
              const Text(
                "JomMakan Contact Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "For any inquiries, users or restaurants will reach out using the contact details below.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              const Text(
                "03 2788 1333",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "storecontact@example.com",
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
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
        title: const Text('Profile'),
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
              _buildIconButton(Icons.people, 'Partners'),
              _buildIconButton(Icons.supervised_user_circle, 'Users'),
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
              _buildIconButton(Icons.phone, 'Store Contact',
                  onTap: _showStoreContactOverlay),
            ],
          ),
          const Divider(height: 40),
          const ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('FAQ'),
          ),
          ListTile(
            leading: const Icon(Icons.contact_support_outlined),
            title: const Text('Contact Technician'),
            onTap: () {
              final int pinNumber = _generateRandomPin();
              _showContactTechnicianOverlay(pinNumber);
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

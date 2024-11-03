// lib/screens/store_details_page.dart
import 'package:flutter/material.dart';
import 'package:folks_app/screens/admins/modify_detail.dart';

class StoreDetailsPage extends StatelessWidget {
  const StoreDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Store"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Preview Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: AssetImage('assets/logo.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Add your preview action here
                    },
                    icon: const Icon(Icons.remove_red_eye),
                    label: const Text("Store Info Preview"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info Box
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      "100%",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ensure store Details are up to date",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                            "Provide relevant, up-to-date details to prioritize a positive customer experience!"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Store Information Section
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'JomMakan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Image.asset(
                  'assets/food.jpeg',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            const Text(
              " A Comprehensive Food Discovery Application",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const Divider(height: 32),

            // Owner's Contact
ListTile(
  leading: const Icon(Icons.contact_phone_outlined),
  title: const Text("Contact Number"),
  subtitle: const Text("(123) 456-7890"), // sample phone number
  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ModifyDetailScreen(fieldType: "phone"),
      ),
    );
  },
),

const Divider(),

ListTile(
  leading: const Icon(Icons.email_outlined),
  title: const Text("Email"),
  subtitle: const Text("example@example.com"), // sample email
  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ModifyDetailScreen(fieldType: "email"),
      ),
    );
  },
),

const Divider(),

ListTile(
  leading: const Icon(Icons.location_on),
  title: const Text("Address"),
  subtitle: const Text("123 Main St, Anytown, USA 12345"), // sample address
  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ModifyDetailScreen(fieldType: "address"),
      ),
    );
  },
),

const Divider(),
          ],
        ),
      ),
    );
  }
}
// lib/screens/store_details_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/providers/store_provider.dart';
import 'package:jom_makan/screens/admins/modify_detail.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:provider/provider.dart';

class StoreDetailsPage extends StatefulWidget {
  const StoreDetailsPage({super.key});

  @override
  _StoreDetailsPageState createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<StoreProvider>(context, listen: false).fetchStore();
    });
  }

  String formatPhoneNumber(String number) {
    if (number.length <= 2) return number;
    if (number.length <= 5) {
      return '${number.substring(0, 2)} ${number.substring(2)}';
    }
    return '${number.substring(0, 2)} ${number.substring(2, 6)} ${number.substring(6)}';
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Store",
          style: GoogleFonts.lato(
            fontSize: 24,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              subtitle: storeProvider.storeNumber != null
                  ? Text(
                      formatPhoneNumber(storeProvider.storeNumber ?? ''),
                    )
                  : const Text(
                      'Not Available',
                    ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModifyDetailScreen(
                        fieldType: "phone",
                        address: storeProvider.storeAddress ?? '',
                        email: storeProvider.storeEmail ?? '',
                        phoneNumber: storeProvider.storeNumber ?? ''),
                  ),
                );
              },
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text("Email"),
              subtitle: Text(
                  storeProvider.storeEmail ?? 'Not Available'), // sample email
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModifyDetailScreen(
                        fieldType: "email",
                        address: storeProvider.storeAddress ?? '',
                        email: storeProvider.storeEmail ?? '',
                        phoneNumber: storeProvider.storeNumber ?? ''),
                  ),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text("Address"),
              subtitle: Text(storeProvider.storeAddress ??
                  'Not Available'), // sample address
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModifyDetailScreen(
                        fieldType: "address",
                        address: storeProvider.storeAddress ?? '',
                        email: storeProvider.storeEmail ?? '',
                        phoneNumber: storeProvider.storeNumber ?? ''),
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

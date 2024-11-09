import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jom_makan/providers/helpitem_provider.dart';
import 'package:jom_makan/screens/restaurant/restaurant_complain.dart'; // Import the ComplaintPage

class SupportPage extends StatefulWidget {
  final String restaurantId;
  SupportPage({required this.restaurantId});

  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  @override
  void initState() {
    super.initState();
    // Fetch help items when the page loads
    Future.microtask(() =>
        Provider.of<HelpItemProvider>(context, listen: false).fetchAllHelpItems());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support"),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "FAQ Section",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Consumer<HelpItemProvider>(
                builder: (context, helpItemProvider, _) {
                  if (helpItemProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (helpItemProvider.helpItems.isEmpty) {
                    return const Center(child: Text("No help items available."));
                  }

                  return ListView.builder(
                    itemCount: helpItemProvider.helpItems.length,
                    itemBuilder: (context, index) {
                      final helpItem = helpItemProvider.helpItems[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ExpansionTile(
                          leading: Icon(
                            Icons.help_outline,
                            color: Colors.blueAccent,
                          ),
                          title: Text(
                            helpItem.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                helpItem.subtitle,
                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                            ),
                          ],
                          iconColor: Colors.blueAccent,
                          collapsedIconColor: Colors.blueAccent,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Contact Us",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.email, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Text("support@jom_makan.com", style: TextStyle(fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.phone, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Text("+123-456-7890", style: TextStyle(fontSize: 15)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to the complaint page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ComplaintPage(userID: widget.restaurantId, userType: 'restaurant')),
                );
              },
              icon: const Icon(
                Icons.report_problem,
                size: 20,
                color: Colors.white,
              ),
              label: const Text(
                'Complaint',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: Colors.black.withOpacity(0.2),
                elevation: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

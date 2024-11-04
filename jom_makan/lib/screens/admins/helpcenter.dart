import 'package:flutter/material.dart';
import 'package:jom_makan/providers/helpitem_provider.dart';
import 'package:jom_makan/screens/admins/faqdetail.dart';
import 'package:jom_makan/screens/admins/helpitemform.dart';
import 'package:jom_makan/screens/admins/setting.dart';
import 'package:provider/provider.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  _HelpCenterScreenState createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<HelpItemProvider>(context, listen: false).fetchAllHelpItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 150,
            color: Colors.green,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                title: const Text('Help Centre'),
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StoreProfilePage()),
                    );
                  },
                ),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'add_faq') {
                        _addFaq();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'add_faq',
                        child: Row(
                          children: [
                            Icon(Icons.add),
                            Text('Add New FAQ'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Consumer<HelpItemProvider>(
                    builder: (context, helpItemProvider, _) {
                      final helpItems = helpItemProvider.helpItems;

                      if (helpItems.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                        ),
                        itemCount: helpItems.length,
                        itemBuilder: (context, index) {
                          final item = helpItems[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FaqDetailScreen(
                                    helpItemId: item.helpItemId,
                                    title: item.title,
                                    subtitle: item.subtitle,
                                  ),
                                ),
                              );
                            },
                            child: SizedBox(
                              height: 120,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/hand.jpg',
                                            width: 18,
                                            height: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              item.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addFaq() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HelpItemFormScreen(),
      ),
    );
  }
}

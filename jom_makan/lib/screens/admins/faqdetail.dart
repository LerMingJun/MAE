import 'package:flutter/material.dart';
import 'package:jom_makan/providers/helpitem_provider.dart';
import 'package:jom_makan/screens/admins/helpitemform.dart';
import 'package:provider/provider.dart';

class FaqDetailScreen extends StatelessWidget {
  final String helpItemId;
  final String title;
  final String subtitle;

  const FaqDetailScreen({super.key, required this.title, required this.subtitle, required this.helpItemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ Detail'),
        backgroundColor: Colors.green,
        actions: [
          // Hamburger menu
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'modify') {
                _modifyFaq(context); // Handle "Modify" action
              } else if (value == 'delete') {
                _deleteFaq(context); // Handle "Delete" action
              }
            },
            itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'modify',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.black),
                  SizedBox(width: 8),
                  Text('Modify'),
                ],
              ),
            ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

void _modifyFaq(BuildContext context) async {
  final updatedData = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => HelpItemFormScreen(
        id: helpItemId,
        existingTitle: title,
        existingSubtitle: subtitle,
      ),
    ),
  );

  if (updatedData != null) {
    // Assuming updatedData is a map with 'title' and 'subtitle' keys
    // Update the FAQ details with the modified data
    // You might want to setState to refresh the screen
    print("Modified FAQ Title: ${updatedData['title']}");
    print("Modified FAQ Subtitle: ${updatedData['subtitle']}");
  }
}


  void _deleteFaq(BuildContext context) {
    // Implement delete confirmation dialog before actual deletion
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete FAQ"),
          content: const Text("Are you sure you want to delete this FAQ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Provider.of<HelpItemProvider>(context, listen: false).deleteHelpItem(helpItemId);
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Return to the previous screen after deletion
                print("FAQ deleted.");
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

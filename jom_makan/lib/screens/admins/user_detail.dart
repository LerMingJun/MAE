import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jom_makan/models/user.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:provider/provider.dart';

class UserDetailsScreen extends StatefulWidget {
  final User user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late User userDetails;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<UserProvider>(context, listen: false)
          .fetchUserInfo(widget.user.userID);

    });
  }
  
  @override
  Widget build(BuildContext context) {
    User user = widget.user;
    final userProvider = Provider.of<UserProvider>(context);
    // Status banner properties
    Color statusColor;
    String statusText;
String? postCount = userProvider.postCount;
String? reviewCount = userProvider.reviewCount; 

    switch (user.status) {
      case 'suspend':
        statusColor = Colors.orange;
        statusText = 'Suspended';
        break;
      case 'delete':
        statusColor = Colors.red;
        statusText = 'Deleted';
        break;
      case 'active':
        statusColor = Colors.blue;
        statusText = 'Active';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown Status';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user.username),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Banner
            Container(
              width: double.infinity, // Full width
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: statusColor,
              child: Center(
                child: Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Image
                  user.profileImage.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            user.profileImage,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          height: 200,
                          color: Colors.grey[300],
                          child:
                              const Center(child: Text('No Image Available')),
                        ),
                  const SizedBox(height: 16),
                  Text("Full Name: ${user.fullName}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Username: ${user.username}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("Email: ${user.email}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                      "Created At: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(user.createdAt.toDate())}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("Number of Post: $postCount",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("Number of Review: $reviewCount",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text("Dietary Preferences:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  user.dietaryPreferences.isEmpty
                      ? const Text("No preference",
                          style: TextStyle(fontSize: 16, color: Colors.grey))
                      : Wrap(
                          spacing: 8.0,
                          children: user.dietaryPreferences.map((preference) {
                            return Chip(label: Text(preference));
                          }).toList(),
                        ),
                  const SizedBox(height: 32),
                  // Action Buttons Section
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 3,
                    children: _buildActionButtons(context, user.status),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context, String status) {
    List<Widget> actionButtons = [];

    if (status == 'suspend') {
      actionButtons.addAll([
        _buildButton(context, 'Recover', Colors.green, () {
          _showConfirmationDialog(context, 'Recover',
              'Are you sure you want to recover this user?');
        }),
        _buildButton(context, 'Delete', Colors.red, () {
          _showDialogWithTextField(context, 'Delete', 'Leave Some Comments.');
        }),
      ]);
    } else if (status == 'active') {
      actionButtons.addAll([
        _buildButton(context, 'Suspend', Colors.orange, () {
          _showDialogWithTextField(context, 'Suspend', 'Leave Some Comments.');
        }),
        _buildButton(context, 'Delete', Colors.red, () {
          _showDialogWithTextField(context, 'Delete', 'Leave Some Comments.');
        }),
      ]);
    } else if (status == 'delete') {
      actionButtons.add(
        _buildButton(context, 'Recover', Colors.green, () {
          _showConfirmationDialog(context, 'Recover',
              'Are you sure you want to recover this user?');
        }),
      );
    }

    return actionButtons;
  }

  Widget _buildButton(
      BuildContext context, String label, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label),
      ),
    );
  }

  void _showDialogWithTextField(
      BuildContext context, String title, String hintText) {
    final TextEditingController textController = TextEditingController();
    UserProvider provider = UserProvider(null);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                maxLength: 150,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 8.0),
                ),
                style: const TextStyle(height: 1.5),
              ),
              const SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String userInput = textController.text.trim();
                if (userInput.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a comment'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (title == 'Delete') {
                  provider.updateUser(widget.user.copyWith(
                      status: "delete", commentByAdmin: userInput));
                } else if (title == 'Suspend') {
                  provider.updateUser(widget.user.copyWith(
                      status: "suspend", commentByAdmin: userInput));
                }
                Navigator.of(context).pop();
              },
              child: Text(title),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(
      BuildContext context, String title, String message) {
    UserProvider provider = UserProvider(null);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (title == 'Recover') {
                  provider.updateUser(
                      widget.user.copyWith(status: 'active', commentByAdmin: ''));
                }
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}

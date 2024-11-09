import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jom_makan/models/complain.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/models/user.dart';
import 'package:jom_makan/providers/complain_provider.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/screens/admins/complain.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:provider/provider.dart';

class ComplainDetailsScreen extends StatefulWidget {
  final Complain complain;

  const ComplainDetailsScreen({super.key, required this.complain});

  @override
  _ComplainDetailsScreenState createState() => _ComplainDetailsScreenState();
}

class _ComplainDetailsScreenState extends State<ComplainDetailsScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    if (widget.complain.userType == 'user') {
      await Provider.of<UserProvider>(context, listen: false)
          .fetchUserDatabyUid(widget.complain.userID);
      // ignore: use_build_context_synchronously
      await Provider.of<UserProvider>(context, listen: false)
          .fetchUserInfo(widget.complain.userID);
    } else if (widget.complain.userType == 'restaurant') {
      await Provider.of<RestaurantProvider>(context, listen: false)
          .fetchRestaurantByID(widget.complain.userID);
    }
    setState(() {
      isLoading = false; // Data has been fetched
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    // Set details based on userType
    final userDetails =
        widget.complain.userType == 'user' ? userProvider.userData : null;
    final restaurantDetails = widget.complain.userType == 'restaurant'
        ? restaurantProvider.restaurant
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complain Details',
          style: GoogleFonts.lato(
            fontSize: 24,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildStatusBanner(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.complain.userType == 'user'
                            ? _buildUserDetails(userDetails)
                            : _buildRestaurantDetails(restaurantDetails),
                        const SizedBox(height: 16),
                        _buildComplainDetails(),
                        const SizedBox(height: 32),
                        _buildFeedbackSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0];
    return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
  }

  Widget _buildFeedbackSection() {
    // Only show feedback section if feedback is not yet provided
    if (widget.complain.feedback.isNotEmpty) {
      return Container(); // Empty if feedback is already provided
    }

    final TextEditingController feedbackController = TextEditingController();

    return GestureDetector(
      onTap: () => _showFeedbackBottomSheet(feedbackController),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.feedback, color: Colors.blue),
            SizedBox(width: 8),
            Text("Provide Feedback",
                style: TextStyle(fontSize: 16, color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  void _showFeedbackBottomSheet(TextEditingController feedbackController) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Feedback",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              // Feedback TextField
              TextField(
                controller: feedbackController,
                maxLength: 150,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: "Leave your feedback here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  String feedback = feedbackController.text.trim();
                  if (feedback.isEmpty) {
                    // Show dialog if feedback is empty
                    _showEmptyFeedbackDialog();
                  } else {
                    _showConfirmationDialog(feedbackController, feedback);
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEmptyFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Feedback Required"),
          content: const Text("Please enter feedback before submitting."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(
      TextEditingController feedbackController, String feedback) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Feedback Submission"),
          content: const Text("Are you sure you want to submit this feedback?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Update complaint with new feedback data
                setState(() {
                  widget.complain.feedback = feedback;
                });

                // Call updateComplain in complainProvider
                Provider.of<ComplainProvider>(context, listen: false)
                    .updateComplain(widget.complain);

                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => const ComplainsPage(),
                      ),
                    )
                    .then((_) => Navigator.of(context).pop());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Feedback submitted successfully!')),
                );
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserDetails(User? userDetails) {
    if (userDetails == null) return const Text('Loading user details...');
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String? postCount = userProvider.postCount;
    String? reviewCount = userProvider.reviewCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display profile image if available
        userDetails.profileImage.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  userDetails.profileImage,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: Text('No Image Available')),
              ),
        const SizedBox(height: 16),
        Text("Full Name: ${userDetails.fullName}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Username: ${userDetails.username}",
            style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Text("Email: ${userDetails.email}",
            style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Text(
            "Created At: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(userDetails.createdAt.toDate())}",
            style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Text("Number of Post: $postCount",
            style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Text("Number of Review: $reviewCount",
            style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        const Text("Dietary Preferences:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        userDetails.dietaryPreferences.isEmpty
            ? const Text("No preference",
                style: TextStyle(fontSize: 16, color: Colors.grey))
            : Wrap(
                spacing: 8.0,
                children: userDetails.dietaryPreferences.map((preference) {
                  return Chip(label: Text(preference));
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildStatusBanner() {
    Color statusColor =
        widget.complain.feedback != "" ? Colors.green : Colors.red;
    String statusText =
        widget.complain.feedback != "" ? 'Resolved' : 'Unresolved';

    return Container(
      width: double.infinity,
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
    );
  }

  Widget _buildRestaurantDetails(Restaurant? restaurantDetails) {
    if (restaurantDetails == null) {
      return const Text('Loading restaurant details...');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant Image
              restaurantDetails.image.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        restaurantDetails.image,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: Text('No Image Available')),
                    ),
              const SizedBox(height: 16),
              // Intro Text
              Text(restaurantDetails.intro,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              // Cuisine Type
              Text("Cuisine: ${restaurantDetails.cuisineType.join(', ')}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Location (with future builder to fetch address from coordinates)
              FutureBuilder<String>(
                future: getAddressFromCoordinates(
                    restaurantDetails.location.latitude,
                    restaurantDetails.location.longitude),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else {
                    return Text("Location: ${snapshot.data}",
                        style: const TextStyle(fontWeight: FontWeight.bold));
                  }
                },
              ),
              const SizedBox(height: 8),
              const Text("Operating Hours:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: restaurantDetails.operatingHours.entries.map((entry) {
                  return Text(
                      "${entry.key}: ${entry.value.open} - ${entry.value.close}");
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Tags
              if (restaurantDetails.tags.isNotEmpty) ...[
                const Text("Tags:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  children: restaurantDetails.tags.map((tag) {
                    return Chip(label: Text(tag));
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComplainDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Complain Details:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(widget.complain.description, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 16),
        // Display feedback if it's available (i.e., resolved)
        if (widget.complain.feedback != "")
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Feedback:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(widget.complain.feedback,
                  style: const TextStyle(fontSize: 16, color: Colors.green)),
            ],
          ),
      ],
    );
  }
}

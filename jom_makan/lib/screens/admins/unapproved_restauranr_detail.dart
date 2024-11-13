import 'package:flutter/material.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/providers/review_provider.dart';
import 'package:jom_makan/screens/admins/mainpage.dart';
import 'package:jom_makan/screens/admins/unapproved_restaurant_list.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';

class UnapprovedRestauranrDetail extends StatelessWidget {
  final Restaurant restaurant;

  UnapprovedRestauranrDetail({super.key, required this.restaurant});

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0];
    return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
  }

  bool _reviewsFetched = false;

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);

    // Status banner properties
    Color statusColor;
    String statusText;

    switch (restaurant.status) {
      case 'Pending':
        statusColor = Colors.orange;
        statusText = 'Pending Approval';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown Status';
        break;
    }

    // Clear reviews when navigating to a new restaurant
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_reviewsFetched) {
        reviewProvider.clearReviews();
        reviewProvider.fetchReviews(restaurant.id);
        _reviewsFetched = true;
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainPage()),
            );
          },
        ),
        title: Text(restaurant.name),
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
                  // Restaurant Image
                  restaurant.image.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            restaurant.image,
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
                  Text(restaurant.intro, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("Cuisine: ${restaurant.cuisineType.join(', ')}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  FutureBuilder<String>(
                    future: getAddressFromCoordinates(
                        restaurant.location.latitude,
                        restaurant.location.longitude),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else {
                        return Text("Location: ${snapshot.data}",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold));
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text("Operating Hours:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: restaurant.operatingHours.entries.map((entry) {
                      return Text(
                          "${entry.key}: ${entry.value.open} - ${entry.value.close}");
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  if (restaurant.tags.isNotEmpty) ...[
                    const Text("Tags:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8.0,
                      children: restaurant.tags.map((tag) {
                        return Chip(label: Text(tag));
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 16),

// Action Buttons for Pending Restaurant
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 3,
                    children: _buildPendingActionButtons(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPendingActionButtons(BuildContext context) {
    return [
      _buildButton(context, 'Approve', Colors.green, () {
        _showConfirmationDialog(context, 'Approve',
            'Are you sure you want to approve this restaurant?');
      }),
      _buildButton(context, 'Decline', Colors.red, () {
        _showDialogWithTextField(context, 'Decline', 'Leave Some Comments.');
      }),
    ];
  }

  Widget _buildButton(
      BuildContext context, String label, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 4.0), // Add space between buttons
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
  RestaurantProvider provider = RestaurantProvider();

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
              maxLines: 6, // Allows the text field to expand to 6 lines
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 8.0,
                ),
              ),
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.updateRestaurant(
                restaurant.copyWith(
                  status: 'Decline', // Sets status to Declined
                  commentByAdmin: textController.text, // Adds admin comment
                ),
              );
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                        builder: (context) =>
                            const UnapprovedRestaurantList()),
                  )
                  .then((_) => Navigator.of(context).pop());
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
}


void _showConfirmationDialog(
    BuildContext context, String title, String message) {
  RestaurantProvider provider = RestaurantProvider();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.updateRestaurant(
                restaurant.copyWith(
                  status: 'Active', // Sets status to Active
                  commentByAdmin: '',
                ),
              );
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                        builder: (context) =>
                            const UnapprovedRestaurantList()),
                  )
                  .then((_) => Navigator.of(context).pop());
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
}

}

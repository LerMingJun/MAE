import 'package:flutter/material.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/providers/review_provider.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/screens/admins/restaurant_list.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';

class RestaurantDetailsScreenAdmin extends StatelessWidget {
  final Restaurant restaurant;

  RestaurantDetailsScreenAdmin({super.key, required this.restaurant});

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
    final userProvider = Provider.of<UserProvider>(context);
                userProvider.fetchUserData();
      final String? userId = userProvider.userData?.userID;
    final reviewProvider = Provider.of<ReviewProvider>(context);

    // Status banner properties
    Color statusColor;
    String statusText;

    switch (restaurant.status) {
      case 'Suspend':
        statusColor = Colors.orange;
        statusText = 'Suspended';
        break;
      case 'Delete':
        statusColor = Colors.red;
        statusText = 'Deleted';
        break;
      case 'Active':
        statusColor = Colors.blue;
        statusText = 'Active';
        break;
      case 'Pending':
        statusColor = Colors.orange;
        statusText = 'Pending Approval';
        break;
      case 'Decline':
        statusColor = Colors.orange;
        statusText = 'Declined';
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Reviews:', style: TextStyle(fontSize: 20)),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/allReviews',
                            arguments: restaurant.id,
                          );
                        },
                        child: const Text('View All Reviews'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Horizontal scrollable reviews
                  Consumer<ReviewProvider>(
                    builder: (context, reviewProvider, _) {
                      return reviewProvider.isLoading
                          ? const SizedBox(
                              height: 100,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : reviewProvider.reviews.isEmpty
                              ? const Text(
                                  'No reviews yet',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                )
                              : SizedBox(
                                  height:
                                      150, // Set a fixed height for the review container
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: reviewProvider.reviews.length,
                                    itemBuilder: (context, index) {
                                      final review =
                                          reviewProvider.reviews[index];
                                      return Container(
                                        width: 250, // Width of each review card
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        child: Card(
                                          elevation: 4,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  review.feedback,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Rating: ${review.rating}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                    },
                  ),

                  const SizedBox(height: 16),

// Action Buttons
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 3,
                    children: _buildActionButtons(context, restaurant.status),
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

    if (status == 'Suspend') {
      actionButtons.addAll([
        _buildButton(context, 'Recover', Colors.green, () {
          _showConfirmationDialog(context, 'Recover',
              'Are you sure you want to recover this restaurant?');
        }),
        _buildButton(context, 'Delete', Colors.red, () {
          _showDialogWithTextField(context, 'Delete', 'Leave Some Comments.');
        }),
      ]);
    } else if (status == 'Active') {
      actionButtons.addAll([
        _buildButton(context, 'Suspend', Colors.orange, () {
          _showDialogWithTextField(context, 'Suspend', 'Leave Some Comments.');
        }),
        _buildButton(context, 'Delete', Colors.red, () {
          _showDialogWithTextField(context, 'Delete', 'Leave Some Comments.');
        }),
      ]);
    } else if (status == 'Pending') {
      actionButtons.addAll([
        _buildButton(context, 'Approve', Colors.green, () {
          _showConfirmationDialog(context, 'Approve',
              'Are you sure you want to approve this restaurant?');
        }),
        _buildButton(context, 'Decline', Colors.red, () {
          _showDialogWithTextField(context, 'Decline', 'Leave Some Comments.');
        }),
      ]);
    } else if (status == 'Decline') {
      actionButtons.addAll([
        _buildButton(context, 'Approve', Colors.green, () {
          _showConfirmationDialog(context, 'Approve',
              'Are you sure you want to approve this restaurant?');
        }),
        _buildButton(context, 'Delete', Colors.red, () {
          _showDialogWithTextField(context, 'Delete', 'Leave Some Comments.');
        }),
      ]);
    } else if (status == 'Delete') {
      actionButtons.add(
        _buildButton(context, 'Recover', Colors.green, () {
          _showConfirmationDialog(context, 'Recover',
              'Are you sure you want to recover this restaurant?');
        }),
      );
    }

    return actionButtons;
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
                maxLines: 6, // Allows the text field to expand to 4 lines
                decoration: InputDecoration(
                  hintText: hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none, // Remove the border color
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 8.0,
                  ),
                ),
                style: const TextStyle(
                    height: 1.5), // Increases line height for readability
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
                String userInput = textController.text
                    .trim(); // trim the text to remove whitespace
                if (userInput.isEmpty) {
                  // show an error message to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a comment'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (title == 'Delete') {
                  // Update isApprove field
                  provider.updateRestaurant(
                    restaurant.copyWith(
                      status: 'Delete',
                      commentByAdmin: userInput,
                    ),
                  );
                } else if (title == 'Decline') {
                  // Update isDecline field
                  provider.updateRestaurant(
                    restaurant.copyWith(
                      status: 'Decline',
                      commentByAdmin: userInput,
                    ),
                  );
                } else if (title == 'Suspend') {
                  // Update isSuspend field
                  provider.updateRestaurant(
                    restaurant.copyWith(
                      status: 'Suspend',
                      commentByAdmin: userInput,
                    ),
                  );
                }
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => const RestaurantsPage(),
                      ),
                    )
                    .then((_) => Navigator.of(context).pop());
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
                    status: 'Active',
                    commentByAdmin: '',
                  ),
                );
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                          builder: (context) => const RestaurantsPage()),
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

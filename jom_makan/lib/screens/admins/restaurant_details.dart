import 'package:flutter/material.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/models/user.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/providers/review_provider.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/screens/admins/restaurant_list.dart';
import 'package:jom_makan/screens/admins/allreview.dart';
import 'package:jom_makan/screens/admins/fullImgae.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';

class RestaurantDetailsScreenAdmin extends StatefulWidget {
  final Restaurant restaurant;

  RestaurantDetailsScreenAdmin({super.key, required this.restaurant});

  @override
  _RestaurantDetailsScreenAdminState createState() =>
      _RestaurantDetailsScreenAdminState();
}

/// Returns an instance of [_RestaurantDetailsScreenAdminState], which is the
/// state class for this widget.
class _RestaurantDetailsScreenAdminState
    extends State<RestaurantDetailsScreenAdmin> {
  @override
  void initState() {
    super.initState();
  }

  bool _reviewsFetched = false;
  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0];
    return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);

    // Status banner properties
    Color statusColor;
    String statusText;

    switch (widget.restaurant.status) {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
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
                  _buildRestaurantImage(),
                  const SizedBox(height: 16),
                  _buildRestaurantIntro(),
                  const SizedBox(height: 16),
                  _buildCuisineType(),
                  const SizedBox(height: 16),
                  _buildLocation(),
                  const SizedBox(height: 16),
                  _buildOperatingHours(),
                  const SizedBox(height: 16),
                  _buildTags(),
                  const Divider(),
                  const Text("Menu Images",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  widget.restaurant.menu.isNotEmpty
                      ? SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.restaurant.menu.length,
                            itemBuilder: (context, index) {
                              final imageUrl = widget.restaurant.menu[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FullScreenImageViewer(
                                        imageUrls: widget
                                            .restaurant.menu, // All menu images
                                        initialIndex:
                                            index, // Start at the tapped image
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 150,
                                  margin: const EdgeInsets.only(right: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Center(
                                              child:
                                                  Text("Image Not Available")),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : const Text("No menu images available",
                          style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  const Divider(),
                  _buildReviewsSection(reviewProvider),
                  const Divider(),
                  const SizedBox(height: 16),
// Action Buttons
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 3,
                    children:
                        _buildActionButtons(context, widget.restaurant.status),
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
                    widget.restaurant.copyWith(
                      status: 'Delete',
                      commentByAdmin: userInput,
                    ),
                  );
                } else if (title == 'Decline') {
                  // Update isDecline field
                  provider.updateRestaurant(
                    widget.restaurant.copyWith(
                      status: 'Decline',
                      commentByAdmin: userInput,
                    ),
                  );
                } else if (title == 'Suspend') {
                  // Update isSuspend field
                  provider.updateRestaurant(
                    widget.restaurant.copyWith(
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
                  widget.restaurant.copyWith(
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

  Widget _buildRestaurantImage() {
    return widget.restaurant.image.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              widget.restaurant.image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        : Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: Text('No Image Available')),
          );
  }

  Widget _buildRestaurantIntro() {
    return Text(
      widget.restaurant.intro,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildCuisineType() {
    return Text(
      "Cuisine: ${widget.restaurant.cuisineType.join(', ')}",
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLocation() {
    return FutureBuilder<String>(
      future: getAddressFromCoordinates(
        widget.restaurant.location.latitude,
        widget.restaurant.location.longitude,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          return Text(
            "Location: ${snapshot.data}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }
      },
    );
  }

  Widget _buildOperatingHours() {
    // Define the correct order for the days of the week
    final orderedDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    // Sort the operating hours based on the defined order
    final sortedOperatingHours = widget.restaurant.operatingHours.entries
        .toList()
      ..sort((a, b) =>
          orderedDays.indexOf(a.key).compareTo(orderedDays.indexOf(b.key)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Operating Hours:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // Display each day in the sorted order
        ...sortedOperatingHours.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(
                left: 10, top: 4), // Add padding above each entry
            child: Text(
                "${entry.key}: ${entry.value.open} - ${entry.value.close}"),
          );
        }),
      ],
    );
  }

  Widget _buildTags() {
    return widget.restaurant.tags.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tags:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8.0,
                children: widget.restaurant.tags.map((tag) {
                  return Chip(label: Text(tag));
                }).toList(),
              ),
            ],
          )
        : Container();
  }

  Widget _buildReviewsSection(ReviewProvider reviewProvider) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_reviewsFetched) {
        reviewProvider.fetchAllReviewsAndReplies(widget.restaurant.id);
        setState(() {
          _reviewsFetched = true;
        });
      }
    });
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final User? user = userProvider.userData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Reviews:', style: TextStyle(fontSize: 20)),
            if (reviewProvider.reviews.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllReviewsScreen(
                        restaurantId: widget.restaurant.id,
                        restaurantName: widget.restaurant.name,
                        user: user,
                      ),
                    ),
                  );
                },
                child: const Text('View All Reviews'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Consumer<ReviewProvider>(
          builder: (context, reviewProvider, _) {
            return reviewProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : reviewProvider.reviews.isEmpty
                    ? const Text(
                        'No reviews yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      )
                    : SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: reviewProvider.reviews.length,
                          itemBuilder: (context, index) {
                            final review = reviewProvider.reviews[index];
                            return _buildReviewCard(
                                review.feedback, review.rating);
                          },
                        ),
                      );
          },
        ),
      ],
    );
  }

  Widget _buildReviewCard(String feedback, double rating) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 10),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            /// 10. The card is also given an elevation of 4.
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feedback,
                style: const TextStyle(fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  5,
                  (starIndex) => Icon(
                    starIndex < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

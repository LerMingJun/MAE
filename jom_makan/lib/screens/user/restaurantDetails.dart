import 'package:flutter/material.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/providers/review_provider.dart';
import 'package:jom_makan/providers/favorite_provider.dart';
import 'package:jom_makan/screens/user/addBooking.dart';
import 'package:jom_makan/screens/user/addReview.dart'; // Import the Leave Review screen
import 'package:jom_makan/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:jom_makan/models/operatingHours.dart'; 


class RestaurantDetailsScreen extends StatefulWidget {
  final Restaurant restaurant;

  RestaurantDetailsScreen({Key? key, required this.restaurant})
      : super(key: key);

  @override
  _RestaurantDetailsScreenState createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  bool _reviewsFetched = false;
  bool _favoritesFetched = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String? userId = userProvider.firebaseUser?.uid;

    // Fetch favorites when the screen is initialized
    if (userId != null && !_favoritesFetched) {
      Provider.of<FavoriteProvider>(context, listen: false)
          .fetchFavorites(userId)
          .then((_) {
        setState(() {
          _favoritesFetched = true; // Mark favorites as fetched
        });
      });
    }
  }

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
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    // Clear reviews when navigating to a new restaurant
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_reviewsFetched) {
        reviewProvider.clearReviews();
        reviewProvider.fetchReviews(widget.restaurant.id);
        _reviewsFetched = true;
      }
    });

    // Ensure favorite status is updated only after fetching favorites
    bool isFavorited = _favoritesFetched
        ? favoriteProvider.isFavorited(widget.restaurant.id)
        : false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
        actions: [
          IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Colors.red : null,
            ),
            onPressed: () {
              final userId = Provider.of<UserProvider>(context, listen: false)
                  .firebaseUser
                  ?.uid;
              if (userId != null) {
                if (isFavorited) {
                  favoriteProvider.removeFavorite(userId, widget.restaurant.id);
                } else {
                  favoriteProvider.addFavorite(userId, widget.restaurant.id);
                }
                // Refresh favorite status after adding/removing
                setState(() {
                  isFavorited = !isFavorited;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.restaurant.image.isNotEmpty
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
                    ),
              const SizedBox(height: 16),
              Text(widget.restaurant.intro,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text("Cuisine: ${widget.restaurant.cuisineType.join(', ')}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              FutureBuilder<String>(
                future: getAddressFromCoordinates(
                    widget.restaurant.location.latitude,
                    widget.restaurant.location.longitude),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else {
                    return Text("Location: ${snapshot.data}",
                        style: const TextStyle(fontWeight: FontWeight.bold));
                  }
                },
              ),
              const SizedBox(height: 8),
              Text("Operating Hours:",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.restaurant.operatingHours.entries.map((entry) {
                  return Text(
                      "${entry.key}: ${entry.value.open} - ${entry.value.close}");
                }).toList(),
              ),
              const SizedBox(height: 16),
              if (widget.restaurant.tags.isNotEmpty) ...[
                Text("Tags:",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  children: widget.restaurant.tags.map((tag) {
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
                        arguments: widget.restaurant.id,
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
                      ? SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : reviewProvider.reviews.isEmpty
                          ? Text(
                              'No reviews yet',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            )
                          : Container(
                              height:
                                  150, // Set a fixed height for the review container
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: reviewProvider.reviews.length,
                                itemBuilder: (context, index) {
                                  final review = reviewProvider.reviews[index];
                                  return Container(
                                    width: 250, // Width of each review card
                                    margin: const EdgeInsets.only(right: 10),
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
                                              style: TextStyle(fontSize: 16),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Rating: ${review.rating}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
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

              // Action buttons arranged in two columns
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true, // Prevent scrolling issues
                physics:
                    NeverScrollableScrollPhysics(), // Disable GridView scrolling
                childAspectRatio: 3, // Maintain aspect ratio
                children: [
                  Padding(
                    padding: const EdgeInsets.all(
                        8.0), // Add padding around the button
                    child: SizedBox(
                      width: 120, // Fixed width for buttons
                      child: ElevatedButton(
                        onPressed: () {
                          final userId =
                              Provider.of<UserProvider>(context, listen: false)
                                  .firebaseUser
                                  ?.uid;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddBookingScreen(
                                restaurant: widget.restaurant,
                                userId: userId ?? '',
                              ),
                            ),
                          );
                        },
                        child: Center(
                          child: const Text(
                            "Make a Reservation",
                            textAlign: TextAlign.center, // Center the text
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(
                        8.0), // Add padding around the button
                    child: SizedBox(
                      width: 120, // Fixed width for buttons
                      child: ElevatedButton(
                        onPressed: () {
                          final userId =
                              Provider.of<UserProvider>(context, listen: false)
                                  .firebaseUser
                                  ?.uid;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LeaveReviewScreen(
                                restaurantId: widget.restaurant.id,
                                userId: userId ?? '',
                              ),
                            ),
                          );
                        },
                        child: Center(
                          child: const Text(
                            "Leave a Review",
                            textAlign: TextAlign.center, // Center the text
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

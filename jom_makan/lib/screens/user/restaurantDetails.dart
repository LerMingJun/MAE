import 'package:flutter/material.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/providers/review_provider.dart';
import 'package:jom_makan/providers/favorite_provider.dart'; // Import the FavoriteProvider
import 'package:jom_makan/screens/user/addReview.dart'; // Import the Leave Review screen
import 'package:jom_makan/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final Restaurant restaurant;

  RestaurantDetailsScreen({Key? key, required this.restaurant})
      : super(key: key);

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
    final String? userId = userProvider.firebaseUser?.uid;
    final reviewProvider = Provider.of<ReviewProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context); // Get the FavoriteProvider

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
        actions: [
          IconButton(
            icon: Icon(
              favoriteProvider.isFavorited(restaurant.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: favoriteProvider.isFavorited(restaurant.id)
                  ? Colors.red
                  : null,
            ),
            onPressed: () {
              if (favoriteProvider.isFavorited(restaurant.id)) {
                favoriteProvider.removeFavorite(userId ?? '', restaurant.id);
              } else {
                favoriteProvider.addFavorite(userId ?? '', restaurant.id);
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
                      child: const Center(child: Text('No Image Available')),
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
                children: restaurant.operatingHours.entries.map((entry) {
                  return Text(
                      "${entry.key}: ${entry.value.open} - ${entry.value.close}");
                }).toList(),
              ),
              const SizedBox(height: 16),
              if (restaurant.tags.isNotEmpty) ...[
                Text("Tags:",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
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
                          // TODO: Navigate to reservation screen
                        },
                        child: Center(
                          // Center the text within the button
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LeaveReviewScreen(
                                restaurantId: restaurant.id,
                                userId: userId ?? '',
                              ),
                            ),
                          );
                        },
                        child: Center(
                          // Center the text within the button
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
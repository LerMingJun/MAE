import 'package:flutter/material.dart';
import 'package:folks_app/models/restaurant.dart';
import 'package:folks_app/providers/review_provider.dart';
import 'package:folks_app/screens/user/addReview.dart'; // Import the Leave Review screen
import 'package:folks_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailsScreen({Key? key, required this.restaurant})
      : super(key: key);

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0];

    // Construct a formatted address string
    return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final String? userId = userProvider.firebaseUser?.uid; // Get user ID
    final reviewProvider = Provider.of<ReviewProvider>(context);

    // Fetch reviews if not already fetched
    if (reviewProvider.reviews.isEmpty) {
      reviewProvider.fetchReviews(restaurant.id);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
      ),
      body: SingleChildScrollView(
        // Allows scrolling if content is too long
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display restaurant image (if any)
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

              // Restaurant details
              Text(
                restaurant.intro,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "Cuisine: ${restaurant.cuisineType.join(', ')}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              
              // Use FutureBuilder to get the address
              FutureBuilder<String>(
                future: getAddressFromCoordinates(
                    restaurant.location.latitude,
                    restaurant.location.longitude),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Show a loading spinner while fetching the address
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}"); // Handle errors
                  } else {
                    return Text(
                      "Location: ${snapshot.data}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),

              // Operating hours
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

              // Tags
              if (restaurant.tags.isNotEmpty) ...[
                Text("Tags:", style: const TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  children: restaurant.tags.map((tag) {
                    return Chip(label: Text(tag));
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Reviews Section
              const SizedBox(height: 16),
              const Text('Reviews:', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              reviewProvider.isLoading
                  ? CircularProgressIndicator()
                  : Column(
                      children: reviewProvider.reviews.take(3).map((review) => ListTile(
                            title: Text(review.feedback),
                            subtitle: Text('Rating: ${review.rating}'),
                          )).toList(),
                    ),

              // Button to view all reviews
              TextButton(
                onPressed: () {
                  // Navigate to the page that shows all reviews
                  Navigator.pushNamed(
                    context,
                    '/allReviews', // Define this route for your all reviews page
                    arguments: restaurant.id,
                  );
                },
                child: Text('View All Reviews'),
              ),

              // Action buttons
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to reservation screen
                },
                child: const Text("Make a Reservation"),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Leave Review screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaveReviewScreen(
                        restaurantId: restaurant.id,
                        userId: userId ?? '', // Pass the current user ID here
                      ),
                    ),
                  );
                },
                child: const Text("Leave a Review"),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement bookmarking functionality
                },
                child: const Text("Bookmark Restaurant"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

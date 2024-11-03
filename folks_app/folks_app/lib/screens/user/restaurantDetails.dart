import 'package:flutter/material.dart';
import 'package:folks_app/models/restaurant.dart';
import 'package:folks_app/providers/review_provider.dart';
import 'package:folks_app/screens/user/addReview.dart'; // Import the Leave Review screen
import 'package:folks_app/providers/user_provider.dart';
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
                future: getAddressFromCoordinates(restaurant.location.latitude,
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
              const Text('Reviews:', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              Consumer<ReviewProvider>(
                builder: (context, reviewProvider, _) {
                  return reviewProvider.isLoading
                      ? CircularProgressIndicator()
                      : reviewProvider.reviews.isEmpty
                          ? Text(
                              'No reviews yet',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            )
                          : Column(
                              children: reviewProvider.reviews
                                  .take(3)
                                  .map((review) => ListTile(
                                        title: Text(review.feedback),
                                        subtitle:
                                            Text('Rating: ${review.rating}'),
                                      ))
                                  .toList(),
                            );
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/allReviews',
                    arguments: restaurant.id,
                  );
                },
                child: Text('View All Reviews'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to reservation screen
                },
                child: const Text("Make a Reservation"),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
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

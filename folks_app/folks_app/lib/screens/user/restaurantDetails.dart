import 'package:flutter/material.dart';
import 'package:folks_app/models/restaurant.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailsScreen({Key? key, required this.restaurant})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display restaurant image (if any)
            restaurant.image.isNotEmpty
                ? Image.network(restaurant.image)
                : Container(
                    height: 200, color: Colors.grey), // Placeholder if no image

            SizedBox(height: 16),

            // Restaurant details
            Text(restaurant.intro, style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Cuisine: ${restaurant.cuisineType.join(', ')}"),
            Text(
                "Location: ${restaurant.location.latitude}, ${restaurant.location.longitude}"),
            SizedBox(height: 8),

            // Operating hours
            Text("Operating Hours:"),
            Column(
              children: restaurant.operatingHours.entries.map((entry) {
                return Text(
                    "${entry.key}: ${entry.value.open} - ${entry.value.close}");
              }).toList(),
            ),

            // Action buttons
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to reservation screen
              },
              child: Text("Make a Reservation"),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to review screen
              },
              child: Text("Leave a Review"),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement bookmarking functionality
              },
              child: Text("Bookmark Restaurant"),
            ),
          ],
        ),
      ),
    );
  }
}

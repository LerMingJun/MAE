import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/models/review.dart'; // Update with your actual path
import 'package:jom_makan/screens/user/restaurantDetails.dart';
import 'package:jom_makan/widgets/custom_text.dart'; // Update with your actual path

class LeaveReviewScreen extends StatefulWidget {
  final String restaurantId;
  final String userId;
  final Restaurant restaurant;

  const LeaveReviewScreen({
    super.key,
    required this.restaurantId,
    required this.userId,
    required this.restaurant,
  });

  @override
  _LeaveReviewScreenState createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  double _rating = 1.0;

  void _submitReview() async {
    if (_feedbackController.text.isNotEmpty && _rating > 0) {
      final review = Review(
        reviewId: '', // Firestore will auto-generate this
        restaurantId: widget.restaurantId,
        userId: widget.userId,
        rating: _rating,
        feedback: _feedbackController.text,
        timestamp: Timestamp.now(),
      );

      // Add the review to Firestore
      await FirebaseFirestore.instance
          .collection('reviews')
          .add(review.toFirestore());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RestaurantDetailsScreen(
            restaurant:
                widget.restaurant, // Pass the updated restaurant if needed
          ),
        ),
      );
    } else {
      // Show an error message if feedback is empty or rating is 0
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide feedback and a rating.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave a Review')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.restaurant.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            const SizedBox(height: 8),
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
            const Divider(),
            CustomNumberText(
              number: _rating.toStringAsFixed(1),
              text: 'Rating',
            ),
            Slider(
              value: _rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: _rating.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            CustomTextField(
              controller: _feedbackController,
              placeholderText: 'Leave your feedback...',
              icon: Icons.feedback,
              obscureText: false,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitReview,
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}

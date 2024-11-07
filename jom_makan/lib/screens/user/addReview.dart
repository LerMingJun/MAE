import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/models/review.dart'; // Update with your actual path
import 'package:jom_makan/widgets/custom_text.dart'; // Update with your actual path

class LeaveReviewScreen extends StatefulWidget {
  final String restaurantId;
  final String userId;

  const LeaveReviewScreen({
    super.key,
    required this.restaurantId,
    required this.userId,
  });

  @override
  _LeaveReviewScreenState createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  double _rating = 0.0;

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
      await FirebaseFirestore.instance.collection('reviews').add(review.toFirestore());
      
      // Optionally, navigate back or show a success message
      Navigator.pop(context);
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomNumberText(
              number: _rating.toStringAsFixed(1),
              text: 'Rating',
            ),
            Slider(
              value: _rating,
              min: 0,
              max: 5,
              divisions: 5,
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
              onChanged: (value) {
                // Optional: Handle text changes
              },
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

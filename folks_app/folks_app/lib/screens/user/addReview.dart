import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddReviewScreen extends StatefulWidget {
  final String restaurantId;  // Pass the restaurant ID

  AddReviewScreen({required this.restaurantId});

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final commentController = TextEditingController();
  double rating = 0.0;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _addReview() async {
    if (_formKey.currentState!.validate()) {
      final reviewData = {
        'userId': 'exampleUserId',  // Replace with the actual user ID
        'rating': rating,
        'comment': commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('reviews')
          .add(reviewData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review added successfully!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Review')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rating: $rating'),
              Slider(
                min: 0,
                max: 5,
                divisions: 5,
                value: rating,
                label: rating.toString(),
                onChanged: (value) {
                  setState(() {
                    rating = value;
                  });
                },
              ),
              TextFormField(
                controller: commentController,
                decoration: InputDecoration(labelText: 'Comment'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a comment';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addReview,
                child: Text('Submit Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
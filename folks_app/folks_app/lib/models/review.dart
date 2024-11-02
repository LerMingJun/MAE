import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String reviewId;
  final String restaurantId;
  final String userId;
  final double rating;
  final String feedback;
  final Timestamp timestamp;

  Review({
    required this.reviewId,
    required this.restaurantId,
    required this.userId,
    required this.rating,
    required this.feedback,
    required this.timestamp,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Review(
      reviewId: doc.id,
      restaurantId: data['restaurantId'],
      userId: data['userId'],
      rating: data['rating']?.toDouble() ?? 0.0,
      feedback: data['feedback'] ?? '',
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'userId': userId,
      'rating': rating,
      'feedback': feedback,
      'timestamp': timestamp,
    };
  }
}
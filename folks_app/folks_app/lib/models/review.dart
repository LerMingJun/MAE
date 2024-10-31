import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String userId;
  final double rating;
  final String comment;
  final Timestamp timestamp;

  Review({
    required this.userId,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  // Create a Review object from Firestore document snapshot
  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Review(
      userId: data['userId'] ?? '',
      rating: (data['rating']?.toDouble() ?? 0.0),
      comment: data['comment'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Convert Review to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
    };
  }
}

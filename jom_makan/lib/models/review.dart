import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/models/reply.dart';

class Review {
  final String reviewId;
  final String restaurantId;
  final String userId;
  final double rating;
  final String feedback;
  final Timestamp timestamp;
  List<Reply> replies;  // A list of replies associated with the review

  Review({
    required this.reviewId,
    required this.restaurantId,
    required this.userId,
    required this.rating,
    required this.feedback,
    required this.timestamp,
    this.replies = const [], // Default empty list for replies
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Convert the replies if any
    var replyData = data['replies'] as List? ?? [];
    List<Reply> replies = replyData
        .map((reply) => Reply.fromFirestore(reply as Map<String, dynamic>, reply['replyId'] as String))
        .toList();

    return Review(
      reviewId: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      userId: data['userId'] ?? '',
      rating: data['rating']?.toDouble() ?? 0.0,
      feedback: data['feedback'] ?? '',
      timestamp: data['timestamp'],
      replies: replies,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'userId': userId,
      'rating': rating,
      'feedback': feedback,
      'timestamp': timestamp,
      'replies': replies.map((reply) => reply.toMap()).toList(), // Convert replies to a list
    };
  }
}
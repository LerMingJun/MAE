import 'package:cloud_firestore/cloud_firestore.dart';

class Reply {
  final String replyId;
  final String reviewId;
  final String replyText;
  final Timestamp timestamp;
  final String? restaurantId;  // Optional
  final String? userId;  // Optional

  Reply({
    required this.replyId,
    required this.reviewId,
    required this.replyText,
    required this.timestamp,
    this.restaurantId,
    this.userId,
  });

  // Convert Firestore document to Reply object
  factory Reply.fromFirestore(Map<String, dynamic> data, String replyId) {
    return Reply(
      replyId: replyId,
      reviewId: data['reviewId'] ?? '',
      replyText: data['replyText'] ?? '',
      timestamp: data['timestamp'],
      restaurantId: data['restaurantId'],
      userId: data['userId'],
    );
  }

  // Convert Reply object to Firestore document format
  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'replyText': replyText,
      'timestamp': timestamp,
      'restaurantId': restaurantId,
      'userId': userId,
    };
  }
}

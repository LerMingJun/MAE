import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String commentId;
  final String postId;
  final String userId;
  final String comment;
  final Timestamp timestamp;

  Comment({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.comment,
    required this.timestamp,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Comment(
      commentId: doc.id,
      postId: data['postId'],
      userId: data['userId'],
      comment: data['comment'] ?? '',
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'userId': userId,
      'comment': comment,
      'timestamp': timestamp,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  final String postId;
  final String userId;
  final String restaurantId;
  final String content;
  final int likes;
  final List<String> tags;
  final Timestamp timestamp;

  CommunityPost({
    required this.postId,
    required this.userId,
    required this.restaurantId,
    required this.content,
    required this.likes,
    required this.tags,
    required this.timestamp,
  });

  factory CommunityPost.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return CommunityPost(
      postId: doc.id,
      userId: data['userId'],
      restaurantId: data['restaurantId'],
      content: data['content'] ?? '',
      likes: data['likes'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'restaurantId': restaurantId,
      'content': content,
      'likes': likes,
      'tags': tags,
      'timestamp': timestamp,
    };
  }
}

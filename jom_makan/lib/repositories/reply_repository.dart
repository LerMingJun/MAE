import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/models/reply.dart';

class ReplyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all replies for a specific review
  Future<List<Reply>> fetchRepliesForReview(String reviewId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reviews')  // Collection for reviews
          .doc(reviewId)  // Specific review document
          .collection('replies')  // Subcollection for replies
          .orderBy('timestamp', descending: true)  // Sort replies by timestamp
          .get();

      // Map snapshot to list of replies using fromFirestore
      return snapshot.docs
          .map((doc) => Reply.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching replies: $e');
      return [];
    }
  }

  // Add a new reply to a review
  Future<void> addReplyToReview(String reviewId, Reply reply) async {
    try {
      await _firestore
          .collection('reviews')  // Collection for reviews
          .doc(reviewId)  // Specific review document
          .collection('replies')  // Subcollection for replies
          .add(reply.toMap());  // Add the new reply using toMap

      print('Reply added successfully');
    } catch (e) {
      print('Error adding reply: $e');
    }
  }

    // Edit an existing reply
  Future<void> updateReply(String reviewId, String replyId, Reply updatedReply) async {
    try {
      await _firestore
          .collection('reviews')  // Collection for reviews
          .doc(reviewId)  // Specific review document
          .collection('replies')  // Subcollection for replies
          .doc(replyId)  // Specific reply document
          .update(updatedReply.toMap());  // Update the reply with the new data

      print('Reply updated successfully');
    } catch (e) {
      print('Error updating reply: $e');
    }
  }

  // Delete a reply
  Future<void> deleteReply(String reviewId, String replyId) async {
    try {
      await _firestore
          .collection('reviews')  // Collection for reviews
          .doc(reviewId)  // Specific review document
          .collection('replies')  // Subcollection for replies
          .doc(replyId)  // Specific reply document
          .delete();  // Delete the reply

      print('Reply deleted successfully');
    } catch (e) {
      print('Error deleting reply: $e');
    }
  }
}

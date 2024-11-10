import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/models/reply.dart';
import 'package:jom_makan/models/review.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch reviews for a specific restaurant
  Future<List<Review>> fetchReviews(String restaurantId) async {
    try {
      print('Fetching reviews for restaurant: $restaurantId');
      QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('restaurantId', isEqualTo: restaurantId)
          .orderBy('timestamp', descending: true) // Most recent reviews first
          // .limit(3) // Limit to 3 reviews for initial display
          .get();

      return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  // Add a new review
  Future<void> addReview(Review review) async {
    try {
      await _firestore.collection('reviews').add(review.toFirestore());
    } catch (e) {
      print('Error adding review: $e');
    }
  }

  // Fetch all reviews for a restaurant (for the "view all" functionality)
  Future<List<Review>> fetchAllReviews(String restaurantId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('restaurantId', isEqualTo: restaurantId)
          .orderBy('timestamp', descending: true) // Most recent reviews first
          .get();

      return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching all reviews: $e');
      return [];
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      final reviewDocRef =
          FirebaseFirestore.instance.collection('reviews').doc(reviewId);

      // Delete all replies in the subcollection 'replies'
      final repliesSnapshot = await reviewDocRef.collection('replies').get();
      for (var replyDoc in repliesSnapshot.docs) {
        await replyDoc.reference.delete();
      }

      // After deleting all replies, delete the review itself
      await reviewDocRef.delete();

      print('Review and its replies deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting review or replies: $e');
      return false;
    }
  }

  Future<List<Reply>> fetchRepliesForReview(String reviewId) async {
    try {
      final reviewDocRef =
          FirebaseFirestore.instance.collection('reviews').doc(reviewId);

      // Delete all replies in the subcollection 'replies'
      final replySnapshot = await reviewDocRef.collection('replies').get();

      return replySnapshot.docs
          .map((doc) => Reply.fromFirestore(doc.data(), doc.id))
          .toList();
      
    } catch (error) {
      throw error;
    }
  }
}

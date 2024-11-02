import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:folks_app/models/review.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch reviews for a specific restaurant
  Future<List<Review>> fetchReviews(String restaurantId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('restaurantId', isEqualTo: restaurantId)
          .orderBy('timestamp', descending: true) // Most recent reviews first
          .limit(3) // Limit to 3 reviews for initial display
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
}

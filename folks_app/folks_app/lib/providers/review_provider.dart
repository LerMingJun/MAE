import 'package:flutter/material.dart';
import 'package:folks_app/models/review.dart';
import 'package:folks_app/repositories/review_repository.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewRepository _reviewRepository = ReviewRepository();
  List<Review> _reviews = [];
  bool _isLoading = false;

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;

  void clearReviews() {
    _reviews = []; // Clear the reviews list
    notifyListeners(); // Notify listeners of the change
  }

  // Fetch initial reviews for a restaurant
  Future<void> fetchReviews(String restaurantId) async {
    if (_isLoading || _reviews.isNotEmpty)
      return; // Prevent multiple fetch calls
    print('Fetching reviews for restaurant: $restaurantId');

    _isLoading = true; // Set loading state
    notifyListeners();

    try {
      _reviews = await _reviewRepository.fetchReviews(restaurantId);
      print('Fetched ${_reviews.length} reviews for restaurant: $restaurantId');
    } catch (e) {
      print('Error fetching reviews: $e');
    } finally {
      _isLoading = false; // Reset loading state
      notifyListeners();
    }
  }

  // Add a new review
  Future<void> addReview(Review review) async {
    await _reviewRepository.addReview(review);
    await fetchReviews(review.restaurantId); // Refresh the reviews after adding
  }

  // Fetch all reviews for viewing all reviews page
  Future<List<Review>> fetchAllReviews(String restaurantId) async {
    return await _reviewRepository.fetchAllReviews(restaurantId);
  }
}

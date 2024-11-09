import 'package:flutter/material.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/models/review.dart';
import 'package:jom_makan/repositories/restaurant_repository.dart';
import 'package:jom_makan/repositories/review_repository.dart';
 
class ReviewProvider with ChangeNotifier {
  final ReviewRepository _reviewRepository = ReviewRepository();
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
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
    if (_isLoading || _reviews.isNotEmpty) {
      return; // Prevent multiple fetch calls
    }
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
 
int countUserReviews(String userId) {
  return _reviews.where((review) => review.userId == userId).length;
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
 
double calculateAverageRating(List<Review> reviews) {
  if (reviews.isEmpty) return 0.0;

  double totalRating = 0.0;

  for (var review in reviews) {
    totalRating += review.rating; // Assuming Review has a 'rating' field
  }

  // Calculate and round to two decimal places
  double averageRating = totalRating / reviews.length;
  return double.parse(averageRating.toStringAsFixed(2));
}

 
    // Fetch reviews for a specific restaurant and calculate the average rating
  Future<double> fetchRestaurantAverageRating(String restaurantId) async {
    try {
 
      List<Review> reviews = await _reviewRepository.fetchReviews(restaurantId);
      return calculateAverageRating(reviews);
    } catch (e) {
      print('Error fetching reviews: $e');
      return 0.0;
    }
  }
 
   Future<Map<String, dynamic>> identifyHighestAndLowestRatedRestaurants() async {
    List<Restaurant> restaurants = await _restaurantRepository.fetchAllRestaurants();
   
    // Placeholder for the highest and lowest rated restaurants
    Restaurant? highestRatingRestaurant;
    Restaurant? lowestRatingRestaurant;
 
    double highestRating = double.negativeInfinity;
    double lowestRating = 5.0;
 
    for (var restaurant in restaurants) {
      // Fetch the average rating for each restaurant
      double averageRating = await fetchRestaurantAverageRating(restaurant.id); // Ensure this function returns the average rating
      // Identify highest rating restaurant
      if (averageRating > highestRating) {
        highestRating = averageRating;
        highestRatingRestaurant = restaurant; // Store restaurant
      }
      // Identify lowest rating restaurant
      if (averageRating < lowestRating && averageRating != 0.0) {
        lowestRating = averageRating;
        lowestRatingRestaurant = restaurant; // Store restaurant
      }
    }
    print({
    'highestRatingRestaurant': highestRatingRestaurant != null
      ? {
        'name': highestRatingRestaurant.name,
        'id': highestRatingRestaurant.id,
        'averageRating': highestRating,
      }
      : null,
    'lowestRatingRestaurant': lowestRatingRestaurant != null
      ? {
        'name': lowestRatingRestaurant.name,
        'id': lowestRatingRestaurant.id,
        'averageRating': lowestRating,
      }
      : null,
  });
    return {
      'highestRatingRestaurant': highestRatingRestaurant != null
          ? {
              'name': highestRatingRestaurant.name,
              'id': highestRatingRestaurant.id,
              'averageRating': highestRating,
            }
          : null,
      'lowestRatingRestaurant': lowestRatingRestaurant != null
          ? {
              'name': lowestRatingRestaurant.name,
              'id': lowestRatingRestaurant.id,
              'averageRating': lowestRating,
            }
          : null,
    };
  }
}
 
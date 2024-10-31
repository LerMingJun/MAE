import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:folks_app/models/restaurant.dart';
import 'package:folks_app/models/review.dart'; // Assuming you have a Review model

class RestaurantRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _restaurantCollection =
      FirebaseFirestore.instance.collection('restaurants');
  final CollectionReference _reviewCollection = FirebaseFirestore.instance
      .collection('reviews'); // Updated collection name

  // Fetch all restaurants
  Future<List<Restaurant>> fetchAllRestaurants() async {
    try {
      QuerySnapshot snapshot = await _restaurantCollection.get();
      print('Fetched ${snapshot.docs.length} restaurants'); // Debugging line

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('Restaurant data: $data'); // Print each restaurant's data
        return Restaurant.fromFirestore(
            doc); // Updated to use DocumentSnapshot directly
      }).toList();
    } catch (e) {
      print(
          'Error fetching all restaurants: $e'); // This will show the exact error
      return [];
    }
  }

  // Fetch restaurants by filtering with specific criteria
  Future<List<Restaurant>> fetchFilteredRestaurants(
      String filter, List<String> reviewIds) async {
    try {
      Query query = _restaurantCollection;

      // Apply filter criteria
      if (filter.isNotEmpty) {
        query = query.where('cuisineType', isEqualTo: filter);
      }

      if (reviewIds.isNotEmpty) {
        // Updated to use reviewIds
        query = query.where('reviews', arrayContainsAny: reviewIds);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs.map((doc) {
        return Restaurant.fromFirestore(
            doc); // Updated to use DocumentSnapshot directly
      }).toList();
    } catch (e) {
      print('Error fetching filtered restaurants: $e');
      return [];
    }
  }

  // Fetch a single restaurant by ID
  Future<Restaurant?> getRestaurantById(String restaurantID) async {
    try {
      DocumentSnapshot snapshot =
          await _restaurantCollection.doc(restaurantID).get();
      if (snapshot.exists) {
        return Restaurant.fromFirestore(
            snapshot); // Return Restaurant object directly
      } else {
        return null; // Return null if restaurant is not found
      }
    } catch (e) {
      print('Error fetching restaurant by ID: $e');
      throw Exception('Error fetching restaurant');
    }
  }

  // Fetch all reviews related to restaurants
  Future<List<Review>> fetchAllReviews() async {
    try {
      QuerySnapshot snapshot = await _reviewCollection.get();
      return snapshot.docs.map((doc) {
        return Review.fromFirestore(
            doc); // Ensure this line matches the Review.fromFirestore method
      }).toList();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }
}

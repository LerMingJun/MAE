import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:folks_app/models/restaurant.dart';
import 'package:folks_app/models/review.dart';

class RestaurantRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _restaurantCollection =
      FirebaseFirestore.instance.collection('restaurants');
final CollectionReference _reviewCollection =       FirebaseFirestore.instance.collection('reviews');


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
  
  // Fetch restaurants with isApprove set to false
Future<List<Restaurant>> fetchUnapprovedRestaurants() async {
  try {
    QuerySnapshot snapshot = await _restaurantCollection
        .where('isApprove', isEqualTo: false)
        .get();

    print('Fetched ${snapshot.docs.length} unapproved restaurants'); // Debugging line

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      print('Unapproved Restaurant data: $data'); // Print each unapproved restaurant's data
      return Restaurant.fromFirestore(doc);
    }).toList();
  } catch (e) {
    print('Error fetching unapproved restaurants: $e'); // This will show the exact error
    print("123");
    return [];
  }
}
// Method to get average rating of a specific restaurant
Future<double> getAverageRating(String restaurantId) async {
  try {
    final CollectionReference ratingCollection = 
        _restaurantCollection.doc(restaurantId).collection('ratings');

    QuerySnapshot snapshot = await ratingCollection.get();
    
    if (snapshot.docs.isEmpty) {
      // If there are no ratings, return 0 as average rating
      return 0.0;
    }

    // Calculate the sum of all rating scores
    double totalRating = 0.0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalRating += data['score'] ?? 0.0; // Assuming each rating document has a 'score' field
    }

    // Calculate the average rating
    double averageRating = totalRating / snapshot.docs.length;
    return averageRating;
  } catch (e) {
    print('Error calculating average rating for restaurant $restaurantId: $e');
    return 0.0; // Return 0 if an error occurs
  }
}
Future<List<Map<String, dynamic>>> fetchAllRestaurantsWithRatings() async {
  List<Restaurant> restaurants = await fetchAllRestaurants();
  List<Map<String, dynamic>> restaurantsWithRatings = [];

  for (var restaurant in restaurants) {
    double averageRating = await getAverageRating(restaurant.id);
    restaurantsWithRatings.add({
      'restaurant': restaurant,
      'averageRating': averageRating,
    });
  }
  
  return restaurantsWithRatings;
}

}

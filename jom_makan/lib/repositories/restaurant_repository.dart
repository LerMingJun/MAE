import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/models/review.dart';

class RestaurantRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _restaurantCollection =
      FirebaseFirestore.instance.collection('restaurants');
  final CollectionReference _reviewCollection =
      FirebaseFirestore.instance.collection('reviews');

  // Fetch all restaurants
  Future<List<Restaurant>> fetchAllRestaurants() async {
    try {
      QuerySnapshot snapshot = await _restaurantCollection.get();
      // print('Fetched ${snapshot.docs.length} restaurants'); // Debugging line

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
          .where("status", isEqualTo: "pending")
          .get();

      print(
          'Fetched ${snapshot.docs.length} unapproved restaurants'); // Debugging line

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print(
            'Unapproved Restaurant data: $data'); // Print each unapproved restaurant's data
        return Restaurant.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print(
          'Error fetching unapproved restaurants: $e'); // This will show the exact error
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
        totalRating += data['score'] ??
            0.0; // Assuming each rating document has a 'score' field
      }

      // Calculate the average rating
      double averageRating = totalRating / snapshot.docs.length;
      return averageRating;
    } catch (e) {
      print(
          'Error calculating average rating for restaurant $restaurantId: $e');
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

  Future<double> calculateAverageRating(String restaurantId) async {
    try {
      // Fetch all reviews for the specific restaurant
      QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      // If no reviews exist for the restaurant, return 0.0
      if (reviewSnapshot.docs.isEmpty) {
        return 0.0;
      }

      double totalRating = 0.0;

      // Iterate through each review and sum up the ratings
      for (var doc in reviewSnapshot.docs) {
        Review review = Review.fromFirestore(doc);

        // Ensure rating is a valid number (fallback to 0 if invalid)
        double rating = review.rating ?? 0.0; // Handle null or missing rating
        totalRating += rating;
      }

      // Calculate and return the average rating
      double averageRating = totalRating / reviewSnapshot.docs.length;

      return averageRating;
    } catch (e) {
      // Handle potential errors
      return 0.0; // Return 0.0 if there was an error
    }
  }

  Future<void> editRestaurant(Restaurant restaurant) async {
    try {
      Map<String, dynamic> updatedData = {
        'status': restaurant.status,
        'commentByAdmin': restaurant.commentByAdmin,
      };

      // Update the store document in Firestore
      await _firestore
          .collection('restaurants')
          .doc(restaurant.id)
          .update(updatedData);
    } catch (e) {
      print('Error updating store: $e');
      throw Exception('Error updating store: $e');
    }
  }

  Future<Restaurant?> getRestaurantData(String uid) async {
    try {
      // Access the restaurant document based on user ID
      DocumentSnapshot doc =
          await _firestore.collection('restaurants').doc(uid).get();

      if (doc.exists) {
        // If the document exists, create a Restaurant instance from it
        return Restaurant.fromFirestore(doc);
      } else {
        print('No restaurant found for the given user ID: $uid');
        return null; // No restaurant found
      }
    } catch (e) {
      print('Error fetching restaurant data: $e');
      return null; // Handle error and return null
    }
  }

  Future<void> updateRestaurantImages({
    required String restaurantId,
    required String profileImageUrl,
    required List<String> menuImageUrls,
  }) async {
    try {
      await _firestore.collection('restaurants').doc(restaurantId).update({
        'image': profileImageUrl,
        'menu': menuImageUrls,
      });
    } catch (e) {
      print("Error updating restaurant images: $e");
    }
  }

  Future<List<Restaurant>> fetchFilteredOrSortedRestaurants(
      List<String> selectedFilter,
      List<String> selectedTags,
      String sortByRatingDesc) async {
    try {
      // Start Firestore query for restaurants collection
      Query query = FirebaseFirestore.instance.collection('restaurants');

      // Apply filter criteria for cuisine type (array-contains-any for multiple cuisines)
      if (selectedFilter.isNotEmpty) {
        query = query.where('cuisineType', arrayContainsAny: selectedFilter);
      }
      // First query for filtered restaurants by cuisineType and location
      QuerySnapshot querySnapshot = await query.get();

      List<Restaurant> filteredRestaurants = [];
      for (var doc in querySnapshot.docs) {
        Restaurant restaurant = Restaurant.fromFirestore(doc);

        // Apply tag filter manually for AND logic
        if (selectedTags.isNotEmpty) {
          bool hasAllTags =
              selectedTags.every((tag) => restaurant.tags.contains(tag));
          if (hasAllTags) {
            filteredRestaurants.add(restaurant);
          }
        } else {
          filteredRestaurants.add(restaurant);
        }
      }

      // Fetch ratings and sort by rating if necessary
      List<Restaurant> restaurants = [];
      for (var restaurant in filteredRestaurants) {
        double averageRating = await calculateAverageRating(restaurant.id);
        restaurant.averageRating = averageRating;
        restaurants.add(restaurant);
      }

      // Sort by average rating if requested
      if (sortByRatingDesc == 'High to Low') {
        restaurants.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      } else if (sortByRatingDesc == 'Low to High') {
        restaurants.sort((a, b) => a.averageRating.compareTo(b.averageRating));
      }

      return restaurants;
    } catch (e) {
      print('Error in fetchFilteredRestaurants in RestaurantRepository: $e');
      return [];
    }
  }
}

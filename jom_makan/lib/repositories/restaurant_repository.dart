import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/constants/collections.dart';
import 'package:jom_makan/models/promotion.dart';
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

  Future<Restaurant?> getRestaurantById(String restaurantID) async {
    try {
      // Fetch the restaurant document
      DocumentSnapshot snapshot =
          await _restaurantCollection.doc(restaurantID).get();

      if (snapshot.exists) {
        // Fetch the promotion subcollection for the specific restaurant
        QuerySnapshot promotionSnapshot = await _restaurantCollection
            .doc(restaurantID)
            .collection('promotion') // The subcollection name
            .get();

        // Retrieve promotion data as a list of Promotion objects
        List<Promotion> promotions = [];
        if (promotionSnapshot.docs.isNotEmpty) {
          promotions = promotionSnapshot.docs.map((doc) {
            // Assuming each promotion document has fields like 'details', 'startDate', 'endDate', etc.
            return Promotion.fromFirestore(doc); // Map to Promotion object
          }).toList();
        }

        // Calculate the average rating for the restaurant
        double averageRating = await calculateAverageRating(restaurantID);
        averageRating = double.parse(averageRating.toStringAsFixed(2));

        // Create a Restaurant instance from Firestore data
        Restaurant restaurant = Restaurant.fromFirestore(snapshot);
        restaurant.averageRating = averageRating; // Set average rating
        restaurant.promotions = promotions; // Set the promotions list

        return restaurant;
      } else {
        return null; // Return null if the restaurant is not found
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
          .where("status", isEqualTo: "Pending")
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

  // Fetch restaurants with isApprove set to false
  Future<List<Restaurant>> fetchActiveRestaurants() async {
    try {
      QuerySnapshot snapshot = await _restaurantCollection
          .where("status", isEqualTo: "Active")
          .get();

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

  Future<void> updateRestaurant(
      String restaurantId, Map<String, dynamic> updatedData) async {
    try {
      await _restaurantCollection.doc(restaurantId).update(updatedData);
    } catch (e) {
      print("Error updating restaurant: $e");
      rethrow;
    }
  }

  Future<bool> updateRestaurantProfile({
    required String restaurantId,
    required String name,
    required GeoPoint location,
    required List<String> cuisineType,
    required Map<String, OperatingHours> operatingHours,
    required String intro,
    required List<String> tags,
  }) async {
    try {
      // Log the parameters to check if they are passed correctly
      print('Updating restaurant profile...');
      print('Restaurant ID: $restaurantId');
      print('Name: $name');
      print('Location: $location');
      print('Cuisine Type: $cuisineType');
      print('Operating Hours: $operatingHours');
      print('Intro: $intro');
      print('Tags: $tags');

      // Convert OperatingHours instances to Map<String, dynamic> for Firestore
      Map<String, Map<String, dynamic>> serializedOperatingHours = {};
      operatingHours.forEach((day, hours) {
        serializedOperatingHours[day] =
            hours.toMap(); // Convert OperatingHours to Map
      });

      final restaurantRef = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId);
      print('Firestore Document Reference: $restaurantRef');

      // Perform Firestore update
      await restaurantRef.update({
        'name': name,
        'location': location,
        'cuisineType': cuisineType,
        'operatingHours':
            serializedOperatingHours, // Send serialized operating hours map
        'intro': intro,
        'tags': tags,
      });

      print('Profile updated successfully');
      return true;
    } catch (e) {
      // Catch any errors and log them
      print("Error updating profile: $e");
      return false;
    }
  }

  Future<void> updateRestaurantProfileImage(
      String restaurantId, String newImageUrl) async {
    try {
      // Reference to the restaurant document in Firestore
      DocumentReference restaurantRef = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId);

      // Update the image URL in the restaurant document
      await restaurantRef.update({
        'image': newImageUrl, // The field where the image URL is stored
      });

      print("Restaurant image updated successfully.");
    } catch (e) {
      print("Error updating restaurant image: $e");
      throw Exception("Failed to update restaurant image.");
    }
  }

  Future<List<Restaurant>> fetchFilteredOrSortedRestaurants(
      List<String> selectedFilter,
      List<String> selectedTags,
      String sortByRatingDesc) async {
    try {
      // Start Firestore query for restaurants collection
      Query query = FirebaseFirestore.instance
          .collection('restaurants')
          .where('status', isEqualTo: 'Active');

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
        restaurant.averageRating =
            double.parse(restaurant.averageRating.toStringAsFixed(2));
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

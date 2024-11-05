import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/models/review.dart'; // Change from Tag to Review
import 'package:jom_makan/repositories/auth_repository.dart';
import 'package:jom_makan/repositories/restaurant_repository.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final AuthRepository _authRepository = AuthRepository();

  Map<String, dynamic>? _highestRatingPartner;
  Map<String, dynamic>? _lowestRatingPartner;
  Map<String, dynamic>? get highestRatingPartner => _highestRatingPartner;
  Map<String, dynamic>? get lowestRatingPartner => _lowestRatingPartner;
  List<Restaurant> _restaurants = [];
  Restaurant? _restaurant;
  List<Restaurant>? _allRestaurants = [];
  List<Review> _reviews = []; // Change from List<Tag> to List<Review>
  bool _isLoading = false;
  LatLng? _center;
  Marker? _marker;
  List<Restaurant> _unapprovedRestaurants = [];
    List<Restaurant> _activeRestaurants = [];
  List<Restaurant> _suspendedRestaurants = [];
  List<Restaurant> _deletedRestaurants = [];

  List<Restaurant> get restaurants => _restaurants;
  List<Review> get reviews => _reviews;
  Restaurant? get restaurant => _restaurant;
  bool get isLoading => _isLoading;
  LatLng? get center => _center;
  Marker? get marker => _marker;
  List<Restaurant> get unapprovedRestaurants => _unapprovedRestaurants;
  Restaurant? _highestRatingRestaurant;
  Restaurant? _lowestRatingRestaurant;
    List<Restaurant> get activeRestaurants => _activeRestaurants;
  List<Restaurant> get suspendedRestaurants => _suspendedRestaurants;
  List<Restaurant> get deletedRestaurants => _deletedRestaurants;

  // Getter methods
  Restaurant? get highestRatingRestaurant => _highestRatingRestaurant;
  Restaurant? get lowestRatingRestaurant => _lowestRatingRestaurant;

  Future<void> fetchAllReviews(String restaurantId) async {
    notifyListeners();
    try {
      _reviews = await _restaurantRepository.fetchAllReviews();
    } catch (e) {
      _reviews = [];
      print('Error in RestaurantProvider: $e');
    }
    notifyListeners();
  }

  Future<void> fetchAllRestaurants() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allRestaurants = await _restaurantRepository.fetchAllRestaurants();
      _restaurants = _allRestaurants ?? [];
      for (var restaurant in _restaurants) {
        double averageRating =
            await _restaurantRepository.calculateAverageRating(restaurant.id);
        restaurant.averageRating = averageRating; // Set the average rating
      }
      print(
          'Number of restaurants loaded: ${_restaurants.length}'); // Debugging line
    } catch (e) {
      _restaurants = [];
      print(
          'Error in RestaurantProvider: $e'); // This will show the error in provider
    }
    _isLoading = false;
    notifyListeners();
  }

  int get totalRestaurantCount {
    return _allRestaurants?.length ?? 0;
  }

  Future<void> fetchFilteredRestaurants(String filter) async {
    _isLoading = true;
    notifyListeners();

    try {
      _restaurants =
          await _restaurantRepository.fetchFilteredRestaurants(filter, []);
    } catch (e) {
      _restaurants = [];
      print('Error in RestaurantProvider: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Restaurant?> fetchRestaurantByID(String restaurantID) async {
    try {
      _restaurant = await _restaurantRepository.getRestaurantById(restaurantID);

      if (_restaurant == null || _restaurant!.location == null) {
        throw Exception('Location data is empty');
      }

      GeoPoint locationGeoPoint = _restaurant!.location;
      _center = LatLng(locationGeoPoint.latitude, locationGeoPoint.longitude);
      _marker = Marker(
        markerId: MarkerId(_restaurant!.id),
        position: _center!,
        infoWindow: InfoWindow(title: _restaurant!.name),
      );

      return _restaurant; // Return the fetched restaurant
    } catch (e) {
      print('Error in RestaurantProvider: $e');
      throw Exception('Error fetching restaurant');
    }
  }

Future<Restaurant?> getRestaurantById(String restaurantID) async {
    try {
      return await _restaurantRepository.getRestaurantById(restaurantID);
    } catch (e) {
      print('Error in RestaurantProvider: $e');
      throw Exception('Error fetching restaurant');
    }
  }

  void searchRestaurants(String searchText) {
    if (searchText.isEmpty) {
      _restaurants = _allRestaurants!;
    } else {
      _restaurants = _allRestaurants!.where((restaurant) {
        return restaurant.name.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<void> fetchUnapprovedRestaurants() async {
    _isLoading = true;
    notifyListeners();

    try {
      _unapprovedRestaurants =
          await _restaurantRepository.fetchUnapprovedRestaurants();
      print(
          'Number of unapproved restaurants loaded: ${_unapprovedRestaurants.length}');
    } catch (e) {
      print('Error fetching unapproved restaurants: $e');
      _unapprovedRestaurants = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  int get unapprovedRestaurantCount {
    return _unapprovedRestaurants.length;
  }

  Future<void> fetchAndProcessRatings() async {
    final restaurantsWithRatings =
        await _restaurantRepository.fetchAllRestaurantsWithRatings();

    if (restaurantsWithRatings.isNotEmpty) {
      _highestRatingPartner = restaurantsWithRatings
          .reduce((a, b) => (a['averageRating'] > b['averageRating']) ? a : b);

      _lowestRatingPartner = restaurantsWithRatings
          .reduce((a, b) => (a['averageRating'] < b['averageRating']) ? a : b);
    } else {
      _highestRatingPartner = null;
      _lowestRatingPartner = null;
    }

    notifyListeners();
  }

  Future<void> _calculateHighestAndLowestRatingRestaurants() async {
    double maxRating = -1;
    double minRating = double.infinity;

    for (var restaurant in _restaurants) {
      double rating =
          await _restaurantRepository.getAverageRating(restaurant.id);

      if (rating > maxRating) {
        maxRating = rating;
        _highestRatingRestaurant = restaurant;
      }

      if (rating < minRating) {
        minRating = rating;
        _lowestRatingRestaurant = restaurant;
      }
    }
  }

    // Method to categorize restaurants into active, suspended, and deleted
  void _categorizeRestaurants() {
    _activeRestaurants = [];
    _suspendedRestaurants = [];
    _deletedRestaurants = [];

    for (var restaurant in _allRestaurants!) {
      if (restaurant.isDelete) {
        _deletedRestaurants.add(restaurant);
      } else if (restaurant.isSuspend) {
        _suspendedRestaurants.add(restaurant);
      } else {
        _activeRestaurants.add(restaurant);
      }
    }

    // Notify listeners to update the UI
    notifyListeners();
  }
  
  // Optional: Method to re-fetch and categorize when there's a status change
  Future<void> refreshRestaurants() async {
    await fetchAllRestaurants();
  }

Future<void> updateRestaurant(Restaurant restaurant) async {
  _isLoading = true;
  notifyListeners();

  try {
    await _restaurantRepository.editRestaurant(restaurant);

    // Fetch updated store details to ensure local data is up-to-date
    await fetchAllRestaurants();

    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    notifyListeners();
    print('Error in StoreProvider: $e');
    throw Exception('Error updating store');
  }
}

}

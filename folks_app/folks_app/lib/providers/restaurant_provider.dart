import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:folks_app/models/restaurant.dart';
import 'package:folks_app/models/review.dart'; // Change from Tag to Review
import 'package:folks_app/repositories/auth_repository.dart';
import 'package:folks_app/repositories/restaurant_repository.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final AuthRepository _authRepository = AuthRepository();

  List<Restaurant> _restaurants = [];
  Restaurant? _restaurant;
  List<Restaurant>? _allRestaurants = [];
  List<Review> _reviews = []; // Change from List<Tag> to List<Review>
  bool _isLoading = false;
  LatLng? _center;
  Marker? _marker;
  List<Restaurant> _unapprovedRestaurants = [];

  List<Restaurant> get restaurants => _restaurants;
  List<Review> get reviews => _reviews; // Change from List<Tag> to List<Review>
  Restaurant? get restaurant => _restaurant;
  bool get isLoading => _isLoading;
  LatLng? get center => _center;
  Marker? get marker => _marker;
  List<Restaurant> get unapprovedRestaurants => _unapprovedRestaurants;

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

  Future<void> fetchRestaurantByID(String restaurantID) async {
    try {
      _restaurant = await _restaurantRepository.getRestaurantById(restaurantID);

      if (_restaurant == null || _restaurant!.location == null) {
        throw Exception('Location data is empty');
      }

      GeoPoint locationGeoPoint =
          _restaurant!.location; // Assuming location is stored as GeoPoint
      _center = LatLng(locationGeoPoint.latitude, locationGeoPoint.longitude);
      _marker = Marker(
        markerId: MarkerId(_restaurant!.id),
        position: _center!,
        infoWindow: InfoWindow(
          title: _restaurant!.name,
        ),
      );
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
      _unapprovedRestaurants = await _restaurantRepository.fetchUnapprovedRestaurants();
      print('Number of unapproved restaurants loaded: ${_unapprovedRestaurants.length}');
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
}


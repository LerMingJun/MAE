import 'package:flutter/material.dart';
import 'package:jom_makan/models/favorite.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/repositories/favorite_repository.dart';
import 'package:jom_makan/repositories/restaurant_repository.dart';

class FavoriteProvider with ChangeNotifier {
  final FavoriteRepository _favoriteRepository = FavoriteRepository();
  final RestaurantRepository _restaurantRepository = RestaurantRepository();

  final List<Restaurant> _favoriteRestaurants = [];
  bool _isLoading = false;

  List<Restaurant> get favoriteRestaurants => _favoriteRestaurants;
  bool get isLoading => _isLoading;

  Future<void> fetchFavorites(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<Favorite> favorites = await _favoriteRepository.fetchFavorites(userId);

      // Clear previous favorites before fetching new ones
      _favoriteRestaurants.clear();

      // Fetch detailed info for each favorite restaurant
      for (var favorite in favorites) {
        Restaurant? restaurant = await _restaurantRepository.getRestaurantById(favorite.restaurantId);
        if (restaurant != null) {
          _favoriteRestaurants.add(restaurant);
        }
      }
    } catch (error) {
      // Handle errors appropriately (e.g., logging)
      print("Error fetching favorites: $error");
      // Optionally, you might want to show a message to the user
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFavorite(String userId, String restaurantId) async {
    // Check if the restaurant is already a favorite
    if (isFavorited(restaurantId)) return;

    _isLoading = true; // Optional: Show loading state
    notifyListeners();

    try {
      await _favoriteRepository.addFavorite(userId, restaurantId);
      Restaurant? restaurant = await _restaurantRepository.getRestaurantById(restaurantId);
      if (restaurant != null) {
        _favoriteRestaurants.add(restaurant);
      }
    } catch (error) {
      // Handle errors appropriately
      print("Error adding favorite: $error");
      // Optionally, show an error message to the user
    } finally {
      _isLoading = false; // Reset loading state
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String userId, String restaurantId) async {
    if (!isFavorited(restaurantId)) return; // Check if it exists before removing

    _isLoading = true; // Optional: Show loading state
    notifyListeners();

    try {
      await _favoriteRepository.removeFavorite(userId, restaurantId);
      _favoriteRestaurants.removeWhere((restaurant) => restaurant.id == restaurantId);
    } catch (error) {
      // Handle errors appropriately
      print("Error removing favorite: $error");
      // Optionally, show an error message to the user
    } finally {
      _isLoading = false; // Reset loading state
      notifyListeners();
    }
  }

  bool isFavorited(String restaurantId) {
    return _favoriteRestaurants.any((restaurant) => restaurant.id == restaurantId);
  }
}

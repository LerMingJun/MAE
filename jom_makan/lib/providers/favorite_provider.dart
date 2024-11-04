import 'package:flutter/material.dart';
import 'package:jom_makan/models/favorite.dart';
import 'package:jom_makan/repositories/favorite_repository.dart';

class FavoriteProvider with ChangeNotifier {
  final FavoriteRepository _favoriteRepository = FavoriteRepository();

  List<Favorite> _favorites = [];
  bool _isLoading = false;

  List<Favorite> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> fetchFavorites(String userId) async {
    _isLoading = true;
    notifyListeners();

    _favorites = await _favoriteRepository.fetchFavorites(userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFavorite(String userId, String restaurantId) async {
    await _favoriteRepository.addFavorite(userId, restaurantId);
    _favorites.add(Favorite(userId: userId, restaurantId: restaurantId));
    notifyListeners();
  }

  Future<void> removeFavorite(String userId, String restaurantId) async {
    await _favoriteRepository.removeFavorite(userId, restaurantId);
    _favorites.removeWhere((favorite) => favorite.restaurantId == restaurantId);
    notifyListeners();
  }

  bool isFavorited(String restaurantId) {
    return _favorites.any((favorite) => favorite.restaurantId == restaurantId);
  }
}

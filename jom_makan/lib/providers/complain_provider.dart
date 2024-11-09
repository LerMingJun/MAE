import 'package:flutter/material.dart';
import 'package:jom_makan/models/complain.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/repositories/complain_repository.dart';

class ComplainProvider with ChangeNotifier {
  final ComplainRepository _complainRepository = ComplainRepository();
  final RestaurantProvider _restaurantProvider = RestaurantProvider();
  final UserProvider _userProvider = UserProvider(null);
  List<Complain> _resolvedComplains = [];
  List<Complain> _unresolvedComplains = [];
  List<Complain> _userComplains = [];
  bool _isLoading = false;

  List<Complain> get resolvedComplains => _resolvedComplains;
  List<Complain> get unresolvedComplains => _unresolvedComplains;
  List<Complain> get userComplains => _userComplains;
  bool get isLoading => _isLoading;
  int get unresolvedComplainCount => _unresolvedComplains.length;

  Future<void> fetchComplains() async {
    // Fetch user complains
    List<Complain> userComplains =
        await _complainRepository.fetchUserComplains();
    print(
        'Fetched ${userComplains.length} user complains'); // Debug print for user complains

    // Fetch restaurant complains
    List<Complain> restaurantComplains =
        await _complainRepository.fetchRestaurantComplains();
    print(
        'Fetched ${restaurantComplains.length} restaurant complains'); // Debug print for restaurant complains

    // Combine both lists
    List<Complain> combinedComplains = [
      ...userComplains,
      ...restaurantComplains
    ];
    print(
        'Total combined complains: ${combinedComplains.length}'); // Debug print for combined complains

    // Classify complains into resolved and unresolved
    _resolvedComplains = combinedComplains
        .where((complain) => complain.feedback.isNotEmpty ?? false)
        .toList();
    _unresolvedComplains = combinedComplains
        .where((complain) => complain.feedback.isEmpty)
        .toList();

    print(
        'Resolved complains count: ${_resolvedComplains.length}'); // Debug print for resolved complains
    print(
        'Unresolved complains count: ${_unresolvedComplains.length}'); // Debug print for unresolved complains

    // Notify listeners of the changes
    notifyListeners();
  }

  Future<void> fetchComplainByUserId(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch the user-specific complaints from the repository
      _userComplains =
          await _complainRepository.fetchUserComplainsByUserId(userId);
    } catch (e) {
      print('Error fetching complaints for user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateComplain(Complain complain) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _complainRepository.editComplain(complain);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error in StoreProvider: $e');
      throw Exception('Error updating store');
    }
  }

  Future<void> addComplain(Complain complain) async {
    try {
      await _complainRepository.addComplain(complain);
      _userComplains.add(complain);
      notifyListeners(); // Notify listeners to update UI if needed
    } catch (e) {
      print('Error adding complaint in provider: $e');
      throw Exception('Error adding complaint in provider: $e');
    }
  }
}

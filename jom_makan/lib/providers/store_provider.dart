import 'package:flutter/material.dart';
import 'package:jom_makan/repositories/store_repository.dart';
import 'package:jom_makan/models/store.dart';

class StoreProvider with ChangeNotifier {
  final StoreRepository _storeRepository = StoreRepository();
  bool _isLoading = false;
  Store? _storeDetail;

  bool get isLoading => _isLoading;
  Store? get storeDetail => _storeDetail;
String? get storeNumber => _storeDetail?.phoneNumber;
String? get storeAddress => _storeDetail?.address;
String? get storeEmail => _storeDetail?.email;

// In store_repository.dart
  Future<Null> fetchStore() async {
    _isLoading = true;
    notifyListeners();

    try {
      _storeDetail = await _storeRepository.fetchStore();
      print('Store detail loaded'); // Debugging line
    } catch (e) {
      _storeDetail = null;
      print('Error in StoreProvider: $e'); // This will show the error in provider
      return null;
    }
    _isLoading = false;
    notifyListeners();
  }

Future<void> updateStore(String storeID, String address, String email, String phoneNumber) async {
  _isLoading = true;
  notifyListeners();

  try {
    await _storeRepository.editStore(storeID, address, email, phoneNumber);

    // Fetch updated store details to ensure local data is up-to-date
    await fetchStore();

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

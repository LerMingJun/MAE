import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:folks_app/repositories/store_repository.dart';
import 'package:folks_app/models/store.dart';

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


}

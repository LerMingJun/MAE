import 'package:flutter/material.dart';
import 'package:jom_makan/models/promotion.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/repositories/promotion_repository.dart';
 
class PromotionProvider with ChangeNotifier {
  final PromotionRepository _promotionRepository = PromotionRepository();
  final RestaurantProvider _restaurantProvider = RestaurantProvider();  

   bool _isLoading = false;
   bool get isLoading => _isLoading;


  Future<void> updatepromotion(Promotion promotion) async {
  _isLoading = true;
  notifyListeners();

  try {
    await _promotionRepository.editPromotion(promotion);

    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    notifyListeners();
    print('Error in StoreProvider: $e');
    throw Exception('Error updating store');
  }
}

  Future<void> submitpromotion(Promotion promotion ) async {
  try {
    await _promotionRepository.addPromotion(promotion);  // Call the repository to add the new promotion
    notifyListeners();  // Notify listeners after the promotiont is added
  } catch (e) {
    print('Error submitting promotion: $e');
    throw Exception('Error submitting promotion: $e');
  }
}

}
 
 
import 'package:flutter/material.dart';
import 'package:jom_makan/models/promotion.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/repositories/promotion_repository.dart';
 
class PromotionProvider with ChangeNotifier {
  final PromotionRepository _promotionRepository = PromotionRepository();
  final RestaurantProvider _restaurantProvider = RestaurantProvider();  

   bool _isLoading = false;
   bool get isLoading => _isLoading;

  Future<void> submitpromotion(Promotion promotion ) async {
  try {
    await _promotionRepository.addPromotion(promotion);  // Call the repository to add the new promotion
    notifyListeners();  // Notify listeners after the promotiont is added
  } catch (e) {
    print('Error submitting promotion: $e');
    throw Exception('Error submitting promotion: $e');
  }
}
  Future<List<Promotion>> getPromotionsByRestaurantId(String restaurantId) async {
    try {
      return await _promotionRepository.fetchPromotions(restaurantId);
    } catch (e) {
      print('Error fetching promotions: $e');
      throw Exception('Error fetching promotions');
    }
  }

  Future<void> deletePromotion(String promotionId, String restaurantId) async {
  try {
    await _promotionRepository.deletePromotion(promotionId, restaurantId);
    notifyListeners();
  } catch (e) {
    print('Error deleting promotion: $e');
    throw Exception('Error deleting promotion: $e');
  }
}
    // Update Existing Promotion
  Future<void> updatePromotion(Promotion updatedPromotion, String promotionId, String restaurantId) async {
  try {
    print('Updating promotion with ID: $promotionId, Restaurant ID: $restaurantId');
    
    // Check if promotionId and restaurantId are empty
    if (promotionId.isEmpty || restaurantId.isEmpty) {
      throw Exception('Promotion ID or Restaurant ID is empty');
    }

    await _promotionRepository.editPromotion(updatedPromotion, promotionId, restaurantId); // Pass promotionId to repository
    notifyListeners();
  } catch (e) {
    print('Error updating promotion: $e');
    throw Exception('Error updating promotion: $e');
  }
}



}
 
 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/models/promotion.dart';
 
class PromotionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _restaurantCollection =
      FirebaseFirestore.instance.collection('restaurants');
 
 
  Future<void> addPromotion(Promotion promotion) async {
    try {
      Map<String, dynamic> newpromotionData = {
        'title': promotion.title,
        'description': promotion.description,  
        'status': promotion.status,
        'discountAmount': promotion.discountAmount,
      };

        await _firestore
            .collection('restaurants')
            .doc(promotion.restaurantId)  
            .collection('promotion')  
            .add(newpromotionData); 

      print('promotiont added successfully');
    } catch (e) {
      print('Error adding promotiont: $e');
      throw Exception('Error adding promotiont: $e');
    }
  }

  // Edit Promotion
Future<void> editPromotion(Promotion promotion, String promotionId, String restaurantId) async {
  try {
    if (promotionId.isEmpty || restaurantId.isEmpty) {
      throw Exception('Promotion ID or Restaurant ID is empty');
    }

    Map<String, dynamic> updatedData = {
      'title': promotion.title,
      'description': promotion.description,
      'status': promotion.status,
      'discountAmount': promotion.discountAmount,
    };

    // Log the updated data to check what is being passed
    print('Updated Data: $updatedData');

    // Log the document path for debugging
    String documentPath = _restaurantCollection
        .doc(restaurantId)
        .collection('promotion')
        .doc(promotionId)
        .path;
    print('Document path: $documentPath');

    await _restaurantCollection
        .doc(restaurantId)
        .collection('promotion')
        .doc(promotionId)  // Ensure promotionId is valid
        .update(updatedData);

    print('Promotion updated successfully');
  } catch (e) {
    print('Error updating promotion: $e');
    throw Exception('Error updating promotion: $e');
  }
}



  Future<List<Promotion>> fetchPromotions(String restaurantId) async {
    try {
      final querySnapshot = await _restaurantCollection
          .doc(restaurantId)
          .collection('promotion')
          .get();
      return querySnapshot.docs
          .map((doc) => Promotion.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching promotions: $e');
      throw Exception('Error fetching promotions');
    }
  }

  Future<void> deletePromotion(String promotionId, String restaurantId) async {
    try {
      // Access the restaurant collection, then the 'promotion' subcollection
      await _firestore
          .collection('restaurants') // Assuming "restaurants" is the main collection
          .doc(restaurantId)
          .collection('promotion') // 'promotion' is the subcollection of the restaurant
          .doc(promotionId) // Reference to the specific promotion document
          .delete();

      print('Promotion deleted successfully');
    } catch (e) {
      print('Error deleting promotion: $e');
      throw Exception('Error deleting promotion: $e');
    }
  }



}


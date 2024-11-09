import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/models/promotion.dart';
 
class PromotionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _restaurantCollection =
      FirebaseFirestore.instance.collection('restaurants');
 
 
    Future<void> editPromotion(
Promotion promotion
  ) async {
  try {
    Map<String, dynamic> updatedData = {
      'status': promotion.status,
      'title': promotion.title,
      'description': promotion.description,
      'discountAmount': promotion.discountAmount,
    };
      // Update the user document in Firestore
        await _firestore.collection('restaurants').doc(promotion.restaurantId).collection('promotion').doc(promotion.id).update(updatedData);

    // Update the store document in Firestore
    // await fetchRestaurantpromotions();
    
  } catch (e) {
    print('Error updating store: $e');
    throw Exception('Error updating store: $e');
  }
}

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


}


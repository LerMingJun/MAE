import 'package:cloud_firestore/cloud_firestore.dart';

class Promotion {
  final String id;
  final String restaurantId;
  final String title;
  final String description;
  final bool status;
  final String discountAmount;

  Promotion({
    required this.id, 
    required this.restaurantId,
    required this.title,
    required this.description,
    required this.status,
    required this.discountAmount
  });

factory Promotion.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    print(data);
    return Promotion(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '', // Default to empty string if null
      description: data['description'] ?? '',
      title: data['title'] ?? '',
      status: data['status'] ?? false ,
      discountAmount: data['discountAmount'] ?? ''
    );
  }

}

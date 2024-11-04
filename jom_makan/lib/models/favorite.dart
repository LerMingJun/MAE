import 'package:cloud_firestore/cloud_firestore.dart';

class Favorite {
  final String userId;
  final String restaurantId;

  Favorite({
    required this.userId,
    required this.restaurantId,
  });

  factory Favorite.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Favorite(
      userId: doc.id,
      restaurantId: data['restaurantId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
    };
  }
}

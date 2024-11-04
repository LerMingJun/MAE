import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/models/favorite.dart';

class FavoriteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Favorite>> fetchFavorites(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => Favorite.fromFirestore(doc)).toList();
      
    } catch (e) {
      print("Error fetching favorites: $e");
      return [];
    }
  }

  Future<void> addFavorite(String userId, String restaurantId) async {
    await _firestore.collection('favorites').add({
      'userId': userId,
      'restaurantId': restaurantId,
    });
  }

  Future<void> removeFavorite(String userId, String restaurantId) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('restaurantId', isEqualTo: restaurantId)
        .get();
        
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}

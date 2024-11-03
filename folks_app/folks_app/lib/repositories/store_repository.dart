import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:folks_app/models/store.dart';

class StoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

final CollectionReference _storeCollection =
      FirebaseFirestore.instance.collection('Store');

Future<Store?> fetchStore() async {
  try {
    DocumentSnapshot snapshot = await _storeCollection.doc('oKONUAJLfS8Pxynj2GHG').get();
    print('Fetched store data: ${snapshot.data()}'); // Debugging line

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      return Store.fromFirestore(snapshot);
    } else {
      print('Store not found');
      return null;
    }
  } catch (e) {
    print('Error fetching store: $e'); // This will show the exact error
    return null;
  }


}

}
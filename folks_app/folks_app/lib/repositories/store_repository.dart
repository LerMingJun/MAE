import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:folks_app/models/restaurant.dart';

class StoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

final CollectionReference _storeCollection =
      FirebaseFirestore.instance.collection('store');

}
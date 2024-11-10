import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Define collection references using final
final CollectionReference userCollection = _firestore.collection('users');
final CollectionReference restaurantCollection = _firestore.collection('restaurants');
final CollectionReference reviewCollection = _firestore.collection('reviews');
final CollectionReference storeCollection = _firestore.collection('store');
final CollectionReference postCollection = _firestore.collection('posts');
final CollectionReference favoriteCollection = _firestore.collection('favorites');
final CollectionReference bookingCollection = _firestore.collection('bookings');


const reviewSubCollection = 'reviews';
const complainSubCollection = 'complain';


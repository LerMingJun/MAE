import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Define collection references using final
final CollectionReference organizerCollection = _firestore.collection('organizers');
final CollectionReference userCollection = _firestore.collection('users');
final CollectionReference eventCollection = _firestore.collection('events');
final CollectionReference speechCollection = _firestore.collection('speeches');
final CollectionReference tagCollection = _firestore.collection('tags');
final CollectionReference restaurantCollection = _firestore.collection('restaurants');
final CollectionReference reviewCollection = _firestore.collection('reviews');

const bookmarkSubCollection = 'bookmarks';
const participationSubCollection = 'participations';
const postSubCollection = 'posts';
const eventSubCollection = 'events';
const speechSubCollection = 'speeches';
const reviewSubCollection = 'reviews';
const complainSubCollection = 'complain';


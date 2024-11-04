import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/models/complain.dart';
 
class ComplainRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _restaurantCollection =
      FirebaseFirestore.instance.collection('restaurants');
 
  Future<List<Complain>> fetchUserComplains() async {
    List<Complain> complains = [];
 
    // Get all documents in the 'users' collection
    QuerySnapshot userSnapshot = await _userCollection.get();
 
    // Iterate through each user document
    for (QueryDocumentSnapshot userDoc in userSnapshot.docs) {
      // Access the 'complain' subcollection for each user
      CollectionReference complainCollection =
          userDoc.reference.collection('complain');
 
      // Fetch documents from the 'complain' subcollection
      QuerySnapshot complainSnapshot = await complainCollection.get();
 
      // Check if any complains were found
      for (QueryDocumentSnapshot complainDoc in complainSnapshot.docs) {
        Map<String, dynamic> complainData =
            complainDoc.data() as Map<String, dynamic>;
 
        // Create a Complain instance and add it to the list
        complains.add(Complain.fromMap(complainData, complainDoc.id, userDoc.id, 'user'));
      }
    }
 
    return complains;
  }
 
  Future<List<Complain>> fetchRestaurantComplains() async {
    List<Complain> complains = [];
 
    // Get all documents in the 'restaurants' collection
    QuerySnapshot restaurantSnapshot = await _restaurantCollection.get();
 
    // Iterate through each restaurant document
    for (QueryDocumentSnapshot restaurantDoc in restaurantSnapshot.docs) {
      // Access the 'complain' subcollection for each restaurant
      CollectionReference complainCollection =
          restaurantDoc.reference.collection('complain');
 
      // Fetch documents from the 'complain' subcollection
      QuerySnapshot complainSnapshot = await complainCollection.get();
 
      // Check if any complains were found
      for (QueryDocumentSnapshot complainDoc in complainSnapshot.docs) {
        Map<String, dynamic> complainData =
            complainDoc.data() as Map<String, dynamic>;
 
        // Create a Complain instance and add it to the list
        complains.add(Complain.fromMap(complainData, complainDoc.id, restaurantDoc.id, 'restaurant'));
      }
    }
 
    return complains;
  }
}
 
 
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

        // Get the user name from the user document
        String userName = userDoc['fullName'];

        // Create a Complain instance with the user name
        complains.add(Complain.fromMap(
          complainData,
          complainDoc.id,
          userDoc.id,
          'user',
          userName,
        ));
      }
    }

    return complains;
  }

  Future<List<Complain>> fetchUserComplainsByUserId(String userId) async {
    List<Complain> complains = [];

    // Get the user document by userId from the 'users' collection
    DocumentSnapshot userDoc = await _userCollection.doc(userId).get();

    // Check if the user exists
    if (userDoc.exists) {
      // Access the 'complain' subcollection for the specific user
      CollectionReference complainCollection =
          userDoc.reference.collection('complain');

      // Fetch documents from the 'complain' subcollection
      QuerySnapshot complainSnapshot = await complainCollection.get();

      // Check if any complains were found
      for (QueryDocumentSnapshot complainDoc in complainSnapshot.docs) {
        Map<String, dynamic> complainData =
            complainDoc.data() as Map<String, dynamic>;

        // Get the user's name from the user document
        String userName = userDoc['fullName'];

        // Create a Complain instance with the user name
        complains.add(Complain.fromMap(
          complainData,
          complainDoc.id,
          userDoc.id,
          'user',
          userName,
        ));
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

        // Get the restaurant name from the restaurant document
        String restaurantName = restaurantDoc['name'];

        // Create a Complain instance with the restaurant name
        complains.add(Complain.fromMap(
          complainData,
          complainDoc.id,
          restaurantDoc.id,
          'restaurant',
          restaurantName,
        ));
      }
    }

    return complains;
  }

  Future<void> editComplain(Complain complain) async {
    try {
      Map<String, dynamic> updatedData = {
        'feedback': complain.feedback,
      };
      if (complain.userType == 'user') {
        // Update the user document in Firestore
        await _firestore
            .collection('users')
            .doc(complain.userID)
            .collection('complain')
            .doc(complain.id)
            .update(updatedData);
      } else if (complain.userType == 'restaurant') {
        await _firestore
            .collection('restaurants')
            .doc(complain.userID)
            .collection('complain')
            .doc(complain.id)
            .update(updatedData);
      } else {
        throw Exception('Invalid user type');
      }
      // Update the store document in Firestore
      await fetchRestaurantComplains();
    } catch (e) {
      print('Error updating store: $e');
      throw Exception('Error updating store: $e');
    }
  }

  Future<void> addComplain(Complain complain) async {
    try {
      Map<String, dynamic> complainData = complain.toMap();

      if (complain.userType == 'user') {
        // Add complain to user's complain subcollection
        await _userCollection
            .doc(complain.userID)
            .collection('complain')
            .add(complainData);
      } else if (complain.userType == 'restaurant') {
        // Add complain to restaurant's complain subcollection
        await _restaurantCollection
            .doc(complain.userID)
            .collection('complain')
            .add(complainData);
      } else {
        throw Exception('Invalid user type');
      }
    } catch (e) {
      print('Error adding complaint: $e');
      throw Exception('Error adding complaint: $e');
    }
  }
}

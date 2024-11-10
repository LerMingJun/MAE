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

  Future<List<Complain>> fetchUserComplainBasedonUserID(
      String userID, String userType) async {
    List<Complain> complains = [];

    try {
      // Check userType and fetch the relevant complaints
      if (userType == 'user') {
        // Fetch complaints for the user
        CollectionReference complainCollection =
            _userCollection.doc(userID).collection('complain');
        QuerySnapshot complainSnapshot = await complainCollection.get();

        for (QueryDocumentSnapshot complainDoc in complainSnapshot.docs) {
          Map<String, dynamic> complainData =
              complainDoc.data() as Map<String, dynamic>;
          String userName =
              'Unknown'; // Replace with actual user name fetch logic if needed

          complains.add(Complain.fromMap(
            complainData,
            complainDoc.id,
            userID,
            'user',
            userName,
          ));
        }
      } else if (userType == 'restaurant') {
        // Fetch complaints for the restaurant
        CollectionReference complainCollection =
            _restaurantCollection.doc(userID).collection('complain');
        QuerySnapshot complainSnapshot = await complainCollection.get();

        for (QueryDocumentSnapshot complainDoc in complainSnapshot.docs) {
          Map<String, dynamic> complainData =
              complainDoc.data() as Map<String, dynamic>;
          String restaurantName =
              'Unknown'; // Replace with actual restaurant name fetch logic if needed

          complains.add(Complain.fromMap(
            complainData,
            complainDoc.id,
            userID,
            'restaurant',
            restaurantName,
          ));
        }
      } else {
        throw Exception('Invalid userType: $userType');
      }
    } catch (e) {
      print('Error fetching complaints for $userID and $userType: $e');
      throw Exception('Error fetching complaints');
    }

    return complains;
  }

  Future<void> addComplain(Complain complain, String userType) async {
    try {
      Map<String, dynamic> newComplainData = {
        'description': complain.description, // Add timestamp to the complaint
        'feedback': complain.feedback,
      };

      // Add a new complaint to the appropriate sub-collection based on the userType
      if (userType == 'user') {
        // Add the new complaint to the user's 'complain' sub-collection
        await _firestore
            .collection('users')
            .doc(complain.userID) // Access the user document
            .collection('complain') // Access the 'complain' sub-collection
            .add(newComplainData); // Add new complaint
      } else if (userType == 'restaurant') {
        // Add the new complaint to the restaurant's 'complain' sub-collection
        await _firestore
            .collection('restaurants')
            .doc(complain.userID) // Access the restaurant document
            .collection('complain') // Access the 'complain' sub-collection
            .add(newComplainData); // Add new complaint
      } else {
        throw Exception('Invalid userType');
      }

      print('Complaint added successfully');
    } catch (e) {
      print('Error adding complaint: $e');
      throw Exception('Error adding complaint: $e');
    }
  }
}

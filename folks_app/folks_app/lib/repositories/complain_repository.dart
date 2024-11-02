import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:folks_app/constants/collections.dart';
import 'package:folks_app/models/complain.dart';

class ComplainRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> fetchUserComplaints() async {
    // Get all documents in the 'users' collection
    QuerySnapshot userSnapshot = await _userCollection.get();

    // Iterate through each user document
    for (QueryDocumentSnapshot userDoc in userSnapshot.docs) {
      // Access the 'complain' subcollection for each user
      CollectionReference complainCollection =
          userDoc.reference.collection('complain');

      // Fetch documents from the 'complain' subcollection
      QuerySnapshot complainSnapshot = await complainCollection.get();

      // Check if any complaints were found
      if (complainSnapshot.docs.isNotEmpty) {
        print('it has complain');
        // Process each complaint document
        for (QueryDocumentSnapshot complaintDoc in complainSnapshot.docs) {
          Map<String, dynamic> complaintData =
              complaintDoc.data() as Map<String, dynamic>;

          // Print the complaint data along with user ID and complaint ID
          print(
              'User ID: ${userDoc.id}, Complaint ID: ${complaintDoc.id}, Data: $complaintData');
        }
      } else {
        // Print a message if no complaints are found for the user
        print('User ID: ${userDoc.id} has no complaints.');
      }
    }
  }
}

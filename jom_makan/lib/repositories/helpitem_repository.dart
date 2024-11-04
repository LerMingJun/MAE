import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/models/help_item.dart';
 
class HelpItemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _helpItemCollection =
      FirebaseFirestore.instance.collection('helpItems');
 
  // Fetch all help items
  Future<List<HelpItem>> fetchAllHelpItems() async {
    try {
      QuerySnapshot snapshot = await _helpItemCollection.get();
      print('Fetched ${snapshot.docs.length} helpItems'); // Debugging line
 
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('helpItem data: $data'); // Print each helpItem's data
        return HelpItem.fromFirestore(
            doc); // Updated to use DocumentSnapshot directly
      }).toList();
    } catch (e) {
      print(
          'Error fetching all helpItems: $e'); // This will show the exact error
      return [];
    }
  }
  Future<HelpItem?> getHelpItemById(String helpItemId) async {
 try {
      DocumentSnapshot snapshot =
          await _helpItemCollection.doc(helpItemId).get();
      if (snapshot.exists) {
        return HelpItem.fromFirestore(
            snapshot); // Return helpItem object directly
      } else {
        return null; // Return null if helpItem is not found
      }
    } catch (e) {
      print('Error fetching helpItem by ID: $e');
      throw Exception('Error fetching helpItem');
    }
  }
 
  Future<void> editHelpItems(
    String helpItemsID,
    String title,
    String subtitle,
  ) async {
  try {
    Map<String, dynamic> updatedData = {
      'title': title,
      'subtitle': subtitle,
    };
 
    // Update the helpItems document in FirehelpItems
    await _firestore.collection('helpItems').doc(helpItemsID).update(updatedData);
  } catch (e) {
    print('Error updating helpItems: $e');
    throw Exception('Error updating helpItems: $e');
  }
}
 
  Future<void> addReview(HelpItem helpItem) async {
    try {
      await _firestore.collection('helpItems').add(helpItem.toFirestore());
    } catch (e) {
      print('Error adding review: $e');
    }
  }
 
  Future<void> deleteHelpItem(String helpItemID) async {
    try {
      // Navigate to the user's posts subcollection and delete the post
      return await _helpItemCollection
          .doc(helpItemID)
          .delete();
    } catch (e) {
      throw Exception('Error deleting post: $e');
    }
  }
 
}
 
 
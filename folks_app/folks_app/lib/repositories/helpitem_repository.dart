import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:folks_app/models/help_item.dart';

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
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/constants/collections.dart';
import 'package:jom_makan/models/bookmark.dart';
import 'package:jom_makan/models/project.dart';
import 'package:jom_makan/models/speech.dart';

class BookmarkRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addBookmark(String userID, String activityID, String type,
      String title, String image, String location, Timestamp hostDate) async {
    try {
      DocumentReference docRef = 
      userCollection
          .doc(userID)
          .collection(bookmarkSubCollection)
          .doc(); // Automatically generates a new document ID

      await docRef.set({
        'bookmarkID': docRef.id,
        'activityID': activityID,
        'type': type,
        'title': title,
        'image': image,
        'location': location,
        'hostDate': hostDate,
      });

    } catch (e) {
      throw Exception('Error adding bookmark: $e');
    }
  }

  Future<void> removeBookmark(String userID, String activityID) async {
    QuerySnapshot snapshot;
    try {
      // Reference to the user's bookmark subcollection
      CollectionReference bookmarkCollection_ =
          userCollection.doc(userID).collection(bookmarkSubCollection);

      // Query the bookmarks based on activityID and type
      snapshot = await bookmarkCollection_
          .where('activityID', isEqualTo: activityID)
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      } else {
        throw Exception(
            'No bookmark found for userID: $userID and activityID: $activityID');
      }
    } catch (e) {
      throw Exception('Error deleting bookmark: $e');
    }
  }

  Future<List<Bookmark>> fetchBookmarksByUserID(String userID) async {
    try {
      QuerySnapshot snapshot = await userCollection
          .doc(userID)
          .collection(bookmarkSubCollection)
          .get();

      return snapshot.docs.map((doc) => Bookmark.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error fetching bookmarks: $e');
    }
  }

  Future<bool> isActivityBookmarked(
      String userID, String activityID) async {
    try {
      QuerySnapshot snapshot = await userCollection
          .doc(userID)
          .collection(bookmarkSubCollection)
          .where('activityID', isEqualTo: activityID)
          .get();

      bool isBookmarked = snapshot.docs.isNotEmpty;
      return isBookmarked;
    } catch (e) {
      print('Error checking bookmark: $e');
      return false;
    }
  }
}

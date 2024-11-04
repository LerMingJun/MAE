import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jom_makan/constants/collections.dart';
import 'package:jom_makan/models/complain.dart';
import 'package:jom_makan/models/participation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jom_makan/models/activity.dart';
import 'package:jom_makan/models/project.dart';
import 'package:jom_makan/models/speech.dart';
import 'package:jom_makan/models/user.dart';

class UserRepository {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _complainsCollection =
      FirebaseFirestore.instance.collection('complain');

  // Get the current user
  auth.User? get currentUser => _firebaseAuth.currentUser;

  // Fetch user data from Firestore
  Future<User?> getUserData(String uid) async {
    try {
      final DocumentSnapshot doc = await userCollection.doc(uid).get();
      if (doc.exists) {
        return User.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<void> updateUserPreferences(
      String userId, List<String> preferences) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'preferences': preferences,
      });
    } catch (e) {
      print('Error updating preferences: $e');
    }
  }
  
  // Fetch user data from Firestore
  Future<void> updateUserData(
      String uid, Map<String, dynamic> data, XFile? imageFile) async {
    try {
      if (imageFile != null) {
        String fileName =
            'users/$uid/profile_${DateTime.now().millisecondsSinceEpoch}.png';
        Reference storageRef = _storage.ref().child(fileName);
        UploadTask uploadTask = storageRef.putFile(File(imageFile.path));
        TaskSnapshot taskSnapshot = await uploadTask;

        // Get download URL
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // Update the data map with the image URL
        data['profileImage'] = downloadUrl;
      }
      await userCollection.doc(uid).update(data);
    } catch (e) {
      print('Error updating user data: $e');
      throw e;
    }
  }

  Future<String> fetchPostCount(String userID) async {
    String postCount = '0';

    try {
      QuerySnapshot postSnapshot =
          await userCollection.doc(userID).collection(postSubCollection).get();

      postCount = postSnapshot.size.toString();
    } catch (e) {
      print('Error fetching postCount: $e');
    }

    return postCount;
  }

  Future<String> fetchLikeCount(String userID) async {
    String likeCount = '0';
    int likeCounts = 0;

    try {
      QuerySnapshot postSnapshot =
          await userCollection.doc(userID).collection(postSubCollection).get();

      for (var doc in postSnapshot.docs) {
        List<dynamic> likes = doc['likes'];
        likeCounts += likes.length;
        likeCount = likeCounts.toString();
      }
    } catch (e) {
      print('Error fetching postCount: $e');
    }

    return likeCount;
  }

  Future<String> fetchParticipationCount(String userID) async {
    String participationCount = '0';

    try {
      QuerySnapshot participationSnapshot = await userCollection
          .doc(userID)
          .collection(participationSubCollection)
          .get();

      participationCount = participationSnapshot.size.toString();
    } catch (e) {
      print('Error fetching postCount: $e');
    }

    return participationCount;
  }

  Future<List<Participation>> fetchUserHistory(String userID) async {
    List<Participation> history = [];
    try {
      QuerySnapshot participationSnapshot = await userCollection
          .doc(userID)
          .collection(participationSubCollection)
          .get();

      history = participationSnapshot.docs
          .map((doc) => Participation.fromFirestore(doc))
          .toList();
      return history;
    } catch (e) {
      print('Error fetching activities: $e');
      throw e;
    }
  }

  Future<List<User>> fetchAllUsers() async {
    try {
      QuerySnapshot snapshot = await _userCollection.get();
      print('Fetched ${snapshot.docs.length} users'); // Debugging line

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('User data: $data'); // Print each user's data
        return User.fromFirestore(
            doc); // Updated to use DocumentSnapshot directly
      }).toList();
    } catch (e) {
      print('Error fetching all users: $e'); // This will show the exact error
      return [];
    }
  }

  Future<void> fetchcomplains() async {
    // Step 1: Get all documents in the 'users' collection
    QuerySnapshot userSnapshot = await _userCollection.get();

    // Step 2: Iterate through each user document
    for (QueryDocumentSnapshot userDoc in userSnapshot.docs) {
      // Step 3: Access the 'complain' subcollection for each user
      CollectionReference complainCollection =
          userDoc.reference.collection('complain');

      // Step 4: Fetch documents from the 'complain' subcollection
      QuerySnapshot complainSnapshot = await complainCollection.get();

      // Step 5: Process each complain document
      for (QueryDocumentSnapshot complainDoc in complainSnapshot.docs) {
        print('complain ID: ${complainDoc.id}');
        print('complain Data: ${complainDoc.data()}');
      }
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>>
      fetchClassifiedcomplains() async {
    Map<String, List<Map<String, dynamic>>> classifiedcomplains = {
      'resolved': [],
      'unresolved': [],
    };

    print("Fetching user documents...");

    // Step 1: Get all documents in the 'users' collection
    QuerySnapshot userSnapshot = await _userCollection.get();
    print("Total users fetched: ${userSnapshot.docs.length}");

    // Step 2: Iterate through each user document
    for (QueryDocumentSnapshot userDoc in userSnapshot.docs) {
      print("Checking complains for user ID: ${userDoc.id}");

      // Step 3: Access the 'complain' subcollection for each user
      CollectionReference complainCollection =
          userDoc.reference.collection('complain');

      // Step 4: Fetch documents from the 'complain' subcollection
      QuerySnapshot complainSnapshot = await complainCollection.get();
      print(
          "Total complains for user ${userDoc.id}: ${complainSnapshot.docs.length}");

      // Step 5: Classify each complain based on 'feedback' attribute
      for (QueryDocumentSnapshot complainDoc in complainSnapshot.docs) {
        Map<String, dynamic> complainData =
            complainDoc.data() as Map<String, dynamic>;

        if (complainData['feedback'] != null) {
          classifiedcomplains['resolved']!.add(complainData);
          print("complain ${complainDoc.id} classified as RESOLVED.");
        } else {
          classifiedcomplains['unresolved']!.add(complainData);
          print("complain ${complainDoc.id} classified as UNRESOLVED.");
        }
      }
    }

    print("Classification complete.");
    print(
        "Total resolved complains: ${classifiedcomplains['resolved']!.length}");
    print(
        "Total unresolved complains: ${classifiedcomplains['unresolved']!.length}");

    return classifiedcomplains;
  }
}
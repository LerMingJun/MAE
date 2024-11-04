import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/constants/collections.dart';
import 'package:jom_makan/models/participation.dart';
import 'package:jom_makan/models/project.dart';
import 'package:jom_makan/models/speech.dart';
import 'package:table_calendar/table_calendar.dart';

class ParticipationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> joinActivity(
      String userID, String id, String image, Timestamp hostDate, String location, String title, String type, int impoints, String organizerID) async {
    DocumentReference docRef;
    try {
      docRef = await userCollection.doc(userID).collection(participationSubCollection).add(
        {
          'hostDate': hostDate,
          'image': image,
          'location': location,
          'title': title,
          'activityID': id,
          'type': type,
          'organizerID': organizerID
        },
      );

      await docRef.update({
        'participationID': docRef.id,
      });

      if (type == 'project') {
        try {
          DocumentReference userDocRef =
              userCollection.doc(userID);

          // Fetch the current points
          DocumentSnapshot userDoc = await userDocRef.get();
          if (!userDoc.exists) {
            throw Exception("User not found");
          }

          int currentPoints = userDoc['impoints'] ?? 0;
          int updatedPoints = currentPoints + impoints;

          // Update the points field
          await userDocRef.update({'impoints': updatedPoints});

        } catch (e) {
          print('Error updating points: $e');
          throw e;
        }
      }
    } catch (e) {
      throw Exception('Error adding participation: $e');
    }
  }

  Future<void> leaveActivity(String userID, String id, String type, int impoints) async {
    QuerySnapshot snapshot;
    try {
      snapshot = await userCollection
          .doc(userID)
          .collection(participationSubCollection)
          .where('activityID', isEqualTo: id)
          .get();

      if (snapshot.docs.isNotEmpty) {
        WriteBatch batch = _firestore.batch();

        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
         // Commit the batch operation
      await batch.commit();

      } else {
        throw Exception(
            'No participation found for userID: $userID and activityID: $id');
      }

      if (type == 'project') {
        try {
          DocumentReference userDocRef =
              userCollection.doc(userID);

          // Fetch the current points
          DocumentSnapshot userDoc = await userDocRef.get();
          if (!userDoc.exists) {
            throw Exception("User not found");
          }

          int currentPoints = userDoc['impoints'] ?? 0;
          int updatedPoints = currentPoints - impoints;

          // Update the points field
          await userDocRef.update({'impoints': updatedPoints});

          print('Points updated successfully');
        } catch (e) {
          print('Error updating points: $e');
          throw e;
        }
      }
    } catch (e) {
      throw Exception('Error deleting participation: $e');
    }
  }

  Future<List<Participation>> fetchAllActivitiesByUserID(String userID) async {
    try {
      // Fetch participation documents directly from the user's subcollection
      QuerySnapshot participationSnapshot = await userCollection
          .doc(userID)
          .collection(participationSubCollection)
          .get();

      // Map participation documents to Participation objects
      List<Participation> activities = participationSnapshot.docs
          .map((doc) => Participation.fromFirestore(doc))
          .toList();

      return activities;
    } catch (e) {
      print('Error fetching activities: $e');
      throw e;
    }
  }

  Future<List<Participation>> fetchPastParticipatedActivities(String userID) async {
    List<Participation> activities = [];
    Timestamp now = Timestamp.now();
  try {
      // Fetch participation documents directly from the user's subcollection
      QuerySnapshot participationSnapshot = await userCollection
          .doc(userID)
          .collection(participationSubCollection)
          .where('hostDate', isLessThan: now)
          .get();

      // Map participation documents to Participation objects
      activities = participationSnapshot.docs
          .map((doc) => Participation.fromFirestore(doc))
          .toList();
      return activities;
    } catch (e) {
      print('Error fetching activities: $e');
      throw e;
    }
  }

}

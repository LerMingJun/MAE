import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:folks_app/constants/collections.dart';
import 'package:folks_app/models/activity.dart';
import 'package:folks_app/models/participation.dart';
import 'package:folks_app/models/project.dart';
import 'package:folks_app/models/projectSpeeches.dart';
import 'package:folks_app/models/speech.dart';
import 'package:folks_app/models/tag.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Tag>> fetchAllTags() async {
    try {
      QuerySnapshot snapshot = await tagCollection.get();

      return snapshot.docs.map((doc) => Tag.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching tags: $e');
      throw e;
    }
  }

  Future<List<Activity>> fetchAllActivities() async {
    List<Activity> activities = [];
    try {
      QuerySnapshot eventSnapshot = await eventCollection
          .where('status', isEqualTo: 'active')
          .where('hostDate', isGreaterThan: Timestamp.now())
          .get();

      activities.addAll(
          eventSnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());

      QuerySnapshot speechSnapshot =
          await speechCollection.where('status', isEqualTo: 'active').get();

      activities.addAll(
          speechSnapshot.docs.map((doc) => Speech.fromFirestore(doc)).toList());

      return activities;
    } catch (e) {
      print('Error fetching activities: $e');
      throw e;
    }
  }

  Future<List<Activity>> fetchFilteredActivities(String filter,
      List<String> tagName, DateTime? startDate, DateTime? endDate) async {
    List<Activity> activities = [];
    try {
      if (filter == 'All' || filter == 'Project') {
        Query eventQuery = eventCollection.where('status', isEqualTo: 'active');
        if (tagName.isNotEmpty) {
          eventQuery = eventQuery.where('tags', arrayContainsAny: tagName);
        }
        if (startDate != null && endDate != null) {
          eventQuery = eventQuery.where('hostDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
          eventQuery = eventQuery.where('hostDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate));
        } else {
          eventQuery =
              eventQuery.where('hostDate', isGreaterThan: Timestamp.now());
        }
        QuerySnapshot eventSnapshot = await eventQuery.get();

        activities.addAll(
            eventSnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
      }

      if (filter == 'All' || filter == 'Speech') {
        Query speechQuery =
            speechCollection.where('status', isEqualTo: 'active');
        if (tagName.isNotEmpty) {
          speechQuery = speechQuery.where('tags', arrayContainsAny: tagName);
        }
        if (startDate != null && endDate != null) {
          speechQuery = speechQuery.where('hostDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
          speechQuery = speechQuery.where('hostDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate));
        }
        QuerySnapshot speechSnapshot = await speechQuery.get();
        activities.addAll(speechSnapshot.docs
            .map((doc) => Speech.fromFirestore(doc))
            .toList());
      }

      return activities;
    } catch (e) {
      print('Error fetching filtered activities: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> getEventById(String eventID) async {
    List<ProjectSpeeches> projectSpeeches = [];
    try {
      print('Fetching event with ID: $eventID');
      DocumentSnapshot doc = await eventCollection.doc(eventID).get();

      if (doc.exists) {
        Event event = Event.fromFirestore(doc);
        event.participants = await fetchUserProfileImages(eventID);

        // Fetch the speeches subcollection
        QuerySnapshot speechSnapshot =
            await doc.reference.collection(speechSubCollection).get();

        if (speechSnapshot.docs.isNotEmpty) {
          projectSpeeches = speechSnapshot.docs
              .map((doc) => ProjectSpeeches.fromFirestore(doc))
              .toList();
        }

        return {
          'event': event,
          'speeches': projectSpeeches,
        };
      } else {
        print('No document found for ID: $eventID');
        throw Exception('Event not found');
      }
    } catch (e) {
      print('Error fetching event: $e');
      throw e;
    }
  }

  Future<List<String>> fetchUserProfileImages(String activityID) async {
    List<String> profileImages = [];
    try {
      QuerySnapshot usersSnapshot = await userCollection.get();

      for (DocumentSnapshot userDoc in usersSnapshot.docs) {
        String userID = userDoc.id;

        QuerySnapshot participationSnapshot = await userCollection
            .doc(userID)
            .collection(participationSubCollection)
            .where('activityID', isEqualTo: activityID)
            .get();

        if (participationSnapshot.docs.isNotEmpty) {
          String profileImage =
              userDoc['profileImage'] ?? 'https://via.placeholder.com/40';
          profileImages.add(profileImage);
        }
      }
    } catch (e) {
      print('Error fetching user profile images: $e');
    }
    return profileImages;
  }

  Future<bool> isActivityJoined(String userID, String id) async {
    QuerySnapshot snapshot;
    try {
      snapshot = await userCollection
          .doc(userID)
          .collection(participationSubCollection)
          .where('activityID', isEqualTo: id)
          .get();

      bool isJoined = snapshot.docs.isNotEmpty;
      return isJoined;
    } catch (e) {
      print('Error checking bookmark: $e');
      return false;
    }
  }
}

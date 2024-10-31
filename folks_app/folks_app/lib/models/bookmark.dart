import 'package:cloud_firestore/cloud_firestore.dart';

class Bookmark {
  final String bookmarkID;
  final String activityID;
  final Timestamp hostDate;
  final String image;
  final String location;
  final String title;
  final String type;

  Bookmark({
    required this.bookmarkID,
    required this.activityID,
    required this.hostDate,
    required this.image,
    required this.location,
    required this.title,
    required this.type,
  });

  factory Bookmark.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Bookmark(
      bookmarkID: data['bookmarkID'],
      activityID: data['activityID'],
      hostDate: data['hostDate'],
      image: data['image'],
      location: data['location'],
      title: data['title'],
      type: data['type'],
    );
  }

  // Method to convert a Bookmark instance to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'bookmarkID': bookmarkID,
      'activityID': activityID,
      'hostDate': hostDate,
      'image': image,
      'location': location,
      'title': title,
      'type': type,

    };
  }
}

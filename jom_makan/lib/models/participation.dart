import 'package:cloud_firestore/cloud_firestore.dart';

class Participation {
  final String participationID;
  final String activityID;
  final Timestamp hostDate;
  final String image;
  final String location;
  final String title;
  final String type;


  Participation({
    required this.participationID,
    required this.activityID,
    required this.hostDate,
    required this.image,
    required this.location,
    required this.title,
    required this.type,
  });

  factory Participation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Participation(
      participationID: data['participationID'],
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
      'participationID': participationID,
      'activityID': activityID,
      'hostDate': hostDate,
      'image': image,
      'location': location,
      'title': title,
      'type': type,
    };
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectSpeeches {
  final String projectSpeechesID;
  final String speechID;
  final String title;
  final Timestamp hostDate;

  ProjectSpeeches({
    required this.projectSpeechesID,
    required this.speechID,
    required this.title,
    required this.hostDate,
  });

  // Factory constructor to create a ProjectWithSpeeches object from Firestore document
  factory ProjectSpeeches.fromFirestore(
      DocumentSnapshot projectDoc) {
    Map<String, dynamic> data = projectDoc.data() as Map<String, dynamic>;
    return ProjectSpeeches(
      projectSpeechesID: data['projectSpeechesID'] ?? '',
      speechID: data['speechID'] ?? '',
      title: data['title'] ?? '',
      hostDate: data['hostDate'],
    );
  }

  // Method to convert ProjectWithSpeeches to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'projectSpeechesID': projectSpeechesID,
      'speechID': speechID,
      'title': title,
      'hostDate': hostDate,
      // speeches field might not be serialized directly; handle speeches separately if needed
    };
  }

}

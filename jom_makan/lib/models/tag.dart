import 'package:cloud_firestore/cloud_firestore.dart';

class Tag {
  final String tagID;
  final String name;

  Tag({
    required this.tagID,
    required this.name,
  });

  factory Tag.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Tag(
      tagID: data['tagID'],
      name: data['name'],
    );
  }

  // Method to convert a Bookmark instance to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'tagID': tagID,
      'name': name,
    };
  }
}

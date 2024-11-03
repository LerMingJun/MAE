import 'package:cloud_firestore/cloud_firestore.dart';

class HelpItem {
  final String id;
  final String title;
  final String subtitle;

  HelpItem({required this.id, required this.title, required this.subtitle});

  factory HelpItem.fromFirestore(DocumentSnapshot snapshot) {
    return HelpItem(
      id: snapshot['id'],
      title: snapshot['title'],
      subtitle: snapshot['subtitle'],
    );
  }
}
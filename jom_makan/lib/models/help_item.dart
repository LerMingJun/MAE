import 'package:cloud_firestore/cloud_firestore.dart';
 
class HelpItem {
  final String helpItemId;
  final String title;
  final String subtitle;
 
  HelpItem({required this.helpItemId, required this.title, required this.subtitle});
 
  factory HelpItem.fromFirestore(DocumentSnapshot doc) {
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
 
    return HelpItem(
      helpItemId: doc.id,
      title: data['title'],
      subtitle: data['subtitle'],
    );
  }
 
    Map<String, dynamic> toFirestore() {
    return {
      'helpItemId': helpItemId,
      'title': title,
      'subtitle': subtitle,
    };
  }
}
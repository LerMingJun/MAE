// models/complaint.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String id;
  final String description;
  final String? feedback;

  Complaint({
    required this.id,
    required this.description,
    this.feedback,
  });

  // Factory constructor to create a Complaint from Firestore data
  factory Complaint.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Complaint(
      id: doc.id,
      description: data['description'] ?? '',
      feedback: data['feedback'], // Null if not present
    );
  }
}

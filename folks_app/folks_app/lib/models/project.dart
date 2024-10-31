import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:folks_app/models/activity.dart';


class Event implements Activity {
  final String eventID;
  final String image;
  final String title;
  final String organizer;
  final String organizerID;
  final String location;
  final Timestamp hostDate;
  final String description;
  final String sdg;
  final int impointsAdd;
  final Timestamp createdAt;
  final String type;
  final String status;
  final List<String> tags; 
  List<String> participants;

  Event({
    required this.eventID,
    required this.image,
    required this.title,
    required this.organizer,
    required this.organizerID,
    required this.location,
    required this.hostDate,
    required this.description,
    required this.sdg,
    required this.impointsAdd,
    required this.createdAt,
    required this.type,
    required this.status,
    required this.tags,
    this.participants = const [],
  });

  @override
  String get id => eventID;

  @override
  String toString() {
    return 'Event: {type: $type, eventID: $eventID, title: $title, organizer: $organizer, location: $location, hostDate: $hostDate, description: $description, sdg: $sdg, impointsAdd: $impointsAdd, createdAt: $createdAt, status: $status}';
  }

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Event(
      eventID: data['eventID'] ?? '',
      image: data['image'] ?? '',
      title: data['title'] ?? '',
      organizer: data['organizer'] ?? '',
      organizerID: data['organizerID'] ?? '',
      location: data['location'] ?? '',
      hostDate: data['hostDate'] ?? Timestamp.now(),
      description: data['description'] ?? '',
      sdg: data['sdg'] ?? '',
      impointsAdd: data['impointsAdd'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      type: data['type'] ?? '',
      status: data['status'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  // Method to convert an Event instance to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'eventID': eventID,
      'image': image,
      'title': title,
      'organizer': organizer,
      'organizerID': organizerID,
      'location': location,
      'hostDate': hostDate,
      'description': description,
      'sdg': sdg,
      'impointsAdd': impointsAdd,
      'createdAt': createdAt,
      'type': type,
      'status': status,
      'tags': tags,
    };
  }
}
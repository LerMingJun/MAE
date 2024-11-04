import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Activity {
  String get id;
  String get image;
  String get title;
  String get organizer;
  String get location;
  Timestamp get hostDate;
  Timestamp get createdAt;
  String get type;
  String get status;
  List<String> get tags;
}

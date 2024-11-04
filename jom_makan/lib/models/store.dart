import 'package:cloud_firestore/cloud_firestore.dart';


class Store {
  final String address;
  final String email;
  final String phoneNumber;

  Store({required this.address, required this.email, required this.phoneNumber});

  factory Store.fromFirestore(DocumentSnapshot snapshot) {
    return Store(
      address: snapshot['address'],
      email: snapshot['email'],
      phoneNumber: snapshot['phoneNumber'],
    );
  }
}
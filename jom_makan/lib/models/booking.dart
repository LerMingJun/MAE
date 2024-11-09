import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/models/restaurant.dart';

class Booking {
  final String bookingId;
  final String userId;
  final String restaurantId;
  final int numberOfPeople;
  final Timestamp timeSlot;
  final String specialRequests;
  String status; // Changed to String
  final String approvalComment;
  Restaurant? restaurantDetails;

  Booking({
    required this.bookingId,
    required this.userId,
    required this.restaurantId,
    required this.numberOfPeople,
    required this.timeSlot,
    required this.specialRequests,
    required this.status,
    this.approvalComment = '',
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Booking(
      bookingId: doc.id,
      userId: data['userId'],
      restaurantId: data['restaurantId'],
      numberOfPeople: data['numberOfPeople'] ?? 0,
      timeSlot: data['timeSlot'],
      specialRequests: data['specialRequests'] ?? '',
      status: data['status'] ?? 'Pending', // Default to "Pending"
      approvalComment: data['approvalComment'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'restaurantId': restaurantId,
      'numberOfPeople': numberOfPeople,
      'timeSlot': timeSlot,
      'specialRequests': specialRequests,
      'status': status, // Save status as string
      'approvalComment': approvalComment,
    };
  }
  
}

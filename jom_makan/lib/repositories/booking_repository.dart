import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/models/booking.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createBooking(Booking booking) async {
    await _firestore.collection('bookings').add(booking.toFirestore());
  }

  Future<List<Booking>> fetchBookings(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
  }

  Future<void> updateBooking(Booking booking) async {
    await _firestore.collection('bookings').doc(booking.bookingId).update(booking.toFirestore());
  }

  Future<void> deleteBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).delete();
  }
}

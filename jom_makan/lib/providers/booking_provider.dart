import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jom_makan/models/booking.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/repositories/booking_repository.dart';

class BookingProvider with ChangeNotifier {
  final BookingRepository _bookingRepository = BookingRepository();
  final RestaurantProvider _restaurantProvider = RestaurantProvider();

  List<Booking> _bookings = [];
  bool _isLoading = false;
  bool _isUpdating = false; // New flag to track update state

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating; // Expose updating state

  // Fetch bookings for a user
  Future<void> fetchBookings(String userId) async {
    _isLoading = true;
    notifyListeners();

    _bookings = await _bookingRepository.fetchBookings(userId);

    for (var booking in _bookings) {
      booking.restaurantDetails =
          await _restaurantProvider.fetchRestaurantByID(booking.restaurantId);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateBooking(Booking booking) async {
    _isUpdating = true; // Set updating to true
    notifyListeners();

    await _bookingRepository
        .updateBooking(booking); // Update the booking in the repository

    // After updating the booking, fetch the updated data
    await fetchBookings(
        booking.userId); // Fetch all bookings again to reflect changes

    _isUpdating = false; // Set updating to false after operation
    notifyListeners();
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      // Get reference to the Firestore document
      final bookingRef =
          FirebaseFirestore.instance.collection('bookings').doc(bookingId);

      // Update the booking status to 'Cancelled'
      await bookingRef.update({
        'status': 'Cancelled',
      });

      // Optionally, notify listeners if needed
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Delete a booking
  Future<void> deleteBooking(String bookingId, String userId) async {
    await _bookingRepository.deleteBooking(bookingId);
    await fetchBookings(userId);
  }
}

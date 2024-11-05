import 'package:flutter/material.dart';
import 'package:jom_makan/models/booking.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/repositories/booking_repository.dart';

class BookingProvider with ChangeNotifier {
  final BookingRepository _bookingRepository = BookingRepository();
  final RestaurantProvider _restaurantProvider = RestaurantProvider();

  List<Booking> _bookings = [];
  bool _isLoading = false;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  // Fetch bookings for a user
  Future<void> fetchBookings(String userId) async {
    _isLoading = true;
    notifyListeners();

    // Fetch bookings from the repository
    _bookings = await _bookingRepository.fetchBookings(userId);

    // Fetch restaurant details for each booking
    for (var booking in _bookings) {
      // Assuming Booking has a restaurantId property
      booking.restaurantDetails = await _restaurantProvider.fetchRestaurantByID(booking.restaurantId);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create a new booking
  Future<void> createBooking(Booking booking) async {
    await _bookingRepository.createBooking(booking);
    await fetchBookings(booking.userId); // Refresh bookings after adding
  }

  // Update an existing booking
  Future<void> updateBooking(Booking booking) async {
    await _bookingRepository.updateBooking(booking);
    await fetchBookings(booking.userId); // Refresh bookings after updating
  }

  // Delete a booking
  Future<void> deleteBooking(String bookingId, String userId) async {
    await _bookingRepository.deleteBooking(bookingId);
    await fetchBookings(userId); // Refresh bookings after deleting
  }
}

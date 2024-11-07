import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/models/booking.dart';
import 'package:provider/provider.dart';
import 'package:jom_makan/providers/booking_provider.dart';

class BookingDetailsPage extends StatelessWidget {
  final Restaurant restaurant;
  final Booking booking;

  const BookingDetailsPage({
    super.key,
    required this.restaurant,
    required this.booking,
  });
  // Method to get the address from latitude and longitude
  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
    } catch (e) {
      return "Address not available";
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.blue;
      case 'Booked':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('MMMM dd, yyyy – hh:mm a').format(booking.timeSlot.toDate());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          restaurant.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Handle favorite button press
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant Image
              restaurant.image.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        restaurant.image,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: Text('No Image Available')),
                    ),
              const SizedBox(height: 16),

              // Cuisine Type
              Text(
                "Cuisine: ${restaurant.cuisineType.join(', ')}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Location
              FutureBuilder<String>(
                future: getAddressFromCoordinates(
                  restaurant.location.latitude,
                  restaurant.location.longitude,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else {
                    return Text(
                      'Location: ${snapshot.data}',
                      style: const TextStyle(fontSize: 16),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),

              // Tags
              if (restaurant.tags.isNotEmpty) ...[
                const Text("Tags:", style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  children: restaurant.tags.map((tag) {
                    return Chip(label: Text(tag));
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Booking Details
              const Divider(),
              const SizedBox(height: 10),
              Text(
                'Booking Date: $formattedDate',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Number of People: ${booking.numberOfPeople}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Special Requests: ${booking.specialRequests == '' ? 'No Special Requests' : booking.specialRequests}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  booking.status,
                  style: TextStyle(
                    color: _getStatusColor(booking.status),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Edit and Cancel Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showEditBookingDialog(context, booking);
                    },
                    child: const Text('Edit Booking'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // _cancelBooking(context, booking.id);
                    },
                    child: const Text('Cancel Booking'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to show the edit booking dialog
  void _showEditBookingDialog(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add form fields for editing booking if necessary
              TextField(
                decoration: InputDecoration(
                  labelText: 'Number of People',
                  hintText: booking.numberOfPeople.toString(),
                ),
                keyboardType: TextInputType.number,
              ),
              // Other fields can be added here as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle the actual booking update here
                Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  // Method to cancel booking
  // void _cancelBooking(BuildContext context, String bookingId) {
  //   final bookingProvider =
  //       Provider.of<BookingProvider>(context, listen: false);
  //   bookingProvider.cancelBooking(bookingId).then((_) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Booking Cancelled')),
  //     );
  //     Navigator.pop(context); // Close the BookingDetailsPage
  //   }).catchError((error) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to cancel booking')),
  //     );
  //   });
  // }
}

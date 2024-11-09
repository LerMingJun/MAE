import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/models/booking.dart';
import 'package:jom_makan/screens/user/restaurantManage.dart';
import 'package:provider/provider.dart';
import 'package:jom_makan/providers/booking_provider.dart';

class BookingDetailsPage extends StatelessWidget {
  final Restaurant restaurant;
  final Booking booking;
  final bool isPastBooking;

  const BookingDetailsPage({
    super.key,
    required this.restaurant,
    required this.booking,
    required this.isPastBooking,
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
      case 'Approved':
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
                const Text("Tags:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                  if (isPastBooking == false) ...[
                    if (booking.status == 'Pending' ||
                        booking.status == 'pending') ...[
                      ElevatedButton(
                        onPressed: () {
                          _showEditBookingDialog(context, booking);
                        },
                        child: const Text('Edit Booking'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _cancelBooking(context, booking.bookingId);
                        },
                        child: const Text('Cancel Booking'),
                      ),
                    ],
                    // Show only the Cancel button if the status is Approved
                    if (booking.status == 'Approved' ||
                        booking.status == 'approved') ...[
                      ElevatedButton(
                        onPressed: () {
                          _cancelBooking(context, booking.bookingId);
                        },
                        child: const Text('Cancel Booking'),
                      ),
                    ],
                    // Do not show any buttons if the status is Cancelled or Completed
                    if (booking.status == 'Cancelled' ||
                        booking.status == 'Completed') ...[
                      // No buttons to display
                    ],
                  ]
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Method to show the edit booking dialog
  void _showEditBookingDialog(BuildContext context, Booking booking) {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    // Create controllers for editable fields
    final TextEditingController peopleController =
        TextEditingController(text: booking.numberOfPeople.toString());
    final TextEditingController requestController =
        TextEditingController(text: booking.specialRequests);
    DateTime selectedDateTime = booking.timeSlot.toDate();

    // Function to show date and time picker
    Future<void> pickDateTime(BuildContext context) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDateTime,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

      if (pickedDate != null) {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
        );

        if (pickedTime != null) {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Booking'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Number of People Field
                TextField(
                  controller: peopleController,
                  decoration: const InputDecoration(
                    labelText: 'Number of People',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),

                // Special Request Field
                TextField(
                  controller: requestController,
                  decoration: const InputDecoration(
                    labelText: 'Special Requests',
                  ),
                ),
                const SizedBox(height: 20),

                // Date and Time Picker
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Booking Date:'),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () async {
                          await pickDateTime(context);
                        },
                        child: Text(
                          DateFormat('MMMM dd, yyyy – hh:mm a')
                              .format(selectedDateTime),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                final updatedPeople = int.tryParse(peopleController.text) ??
                    booking.numberOfPeople;
                final updatedRequests = requestController.text;
                final updatedDateTime = Timestamp.fromDate(selectedDateTime);

                final updatedBooking = Booking(
                  bookingId: booking.bookingId,
                  userId: booking.userId,
                  restaurantId: booking.restaurantId,
                  timeSlot: updatedDateTime,
                  numberOfPeople: updatedPeople,
                  specialRequests: updatedRequests,
                  status: booking.status,
                );

                bookingProvider.updateBooking(updatedBooking).then((_) {
                  // After the update, navigate back and refresh the data
                  Navigator.pop(context); // Close the edit dialog
                  // Push the page again with the updated data
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetailsPage(
                        restaurant:
                            restaurant, // Pass the updated restaurant if needed
                        booking: updatedBooking,
                        isPastBooking: false,
                      ),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Booking updated successfully')),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update booking')),
                  );
                });
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _cancelBooking(BuildContext context, String bookingId) {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);

    // Show a confirmation dialog before proceeding
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Cancellation'),
          content: const Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () {
                // Proceed with the cancellation
                final updatedBooking = Booking(
                  bookingId: bookingId,
                  userId: booking.userId,
                  restaurantId: booking.restaurantId,
                  timeSlot: booking.timeSlot,
                  numberOfPeople: booking.numberOfPeople,
                  specialRequests: booking.specialRequests,
                  status: "Cancelled",
                );

                // Call the cancelBooking method from the provider
                bookingProvider.updateBooking(updatedBooking).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking Cancelled')),
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetailsPage(
                        restaurant:
                            restaurant, // Pass the updated restaurant if needed
                        booking: updatedBooking,
                        isPastBooking: true,
                      ),
                    ),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to cancel booking')),
                  );
                });

                // Close the dialog
                Navigator.pop(context);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog without doing anything
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}

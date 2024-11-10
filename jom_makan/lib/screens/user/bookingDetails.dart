import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/models/booking.dart';
import 'package:jom_makan/screens/user/restaurantManage.dart';
import 'package:jom_makan/widgets/custom_loading.dart';
import 'package:provider/provider.dart';
import 'package:jom_makan/providers/booking_provider.dart';

class BookingDetailsPage extends StatefulWidget {
  final Restaurant restaurant;
  final Booking booking;
  final bool isPastBooking;

  const BookingDetailsPage({
    super.key,
    required this.restaurant,
    required this.booking,
    required this.isPastBooking,
  });

  @override
  _BookingDetailsPageState createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  bool isLoading = false;

  Future<void> _showLoadingDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (BuildContext context) {
        return CustomLoading(text: 'Processing...');
      },
    );
  }

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
    String formattedDate = DateFormat('MMMM dd, yyyy – hh:mm a')
        .format(widget.booking.timeSlot.toDate());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.restaurant.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const CustomLoading(text: 'Processing...')
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant Image
                    widget.restaurant.image.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              widget.restaurant.image,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            height: 200,
                            color: Colors.grey[300],
                            child:
                                const Center(child: Text('No Image Available')),
                          ),
                    const SizedBox(height: 16),

                    // Cuisine Type
                    Text(
                      "Cuisine: ${widget.restaurant.cuisineType.join(', ')}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Location
                    FutureBuilder<String>(
                      future: getAddressFromCoordinates(
                        widget.restaurant.location.latitude,
                        widget.restaurant.location.longitude,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                    if (widget.restaurant.tags.isNotEmpty) ...[
                      const Text("Tags:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8.0,
                        children: widget.restaurant.tags.map((tag) {
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
                      'Number of People: ${widget.booking.numberOfPeople}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Special Requests: ${widget.booking.specialRequests == '' ? 'No Special Requests' : widget.booking.specialRequests}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.booking.status)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.booking.status,
                        style: TextStyle(
                          color: _getStatusColor(widget.booking.status),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (widget.isPastBooking == false) ...[
                          if (widget.booking.status == 'Pending') ...[
                            ElevatedButton(
                              onPressed: () {
                                _showEditBookingDialog(context, widget.booking);
                              },
                              child: const Text('Edit Booking'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _cancelBooking(
                                    context, widget.booking.bookingId);
                              },
                              child: const Text('Cancel Booking'),
                            ),
                          ],
                          if (widget.booking.status == 'Approved') ...[
                            ElevatedButton(
                              onPressed: () {
                                _cancelBooking(
                                    context, widget.booking.bookingId);
                              },
                              child: const Text('Cancel Booking'),
                            ),
                          ],
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _showEditBookingDialog(BuildContext context, Booking booking) async {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    final TextEditingController peopleController =
        TextEditingController(text: booking.numberOfPeople.toString());
    final TextEditingController requestController =
        TextEditingController(text: booking.specialRequests);
    DateTime selectedDateTime = booking.timeSlot.toDate();

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
              onPressed: () async {
                // Show loading dialog before saving
                _showLoadingDialog(context);

                setState(() => isLoading = true);
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

                // Use Future.delayed to safely access context and show the SnackBar
                bookingProvider.updateBooking(updatedBooking).then((_) {
                  if (mounted) {
                    // Delay the SnackBar to ensure context is still valid
                    Future.delayed(Duration.zero, () {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Booking updated successfully')),
                        );
                      }
                    });

                    Navigator.pop(context); // Close the edit dialog
                    Navigator.pop(context); // Close the loading dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingDetailsPage(
                          restaurant: widget.restaurant,
                          booking: updatedBooking,
                          isPastBooking: false,
                        ),
                      ),
                    );
                  }
                }).catchError((error) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update booking')),
                    );
                  }
                }).whenComplete(() {
                  if (mounted) {
                    setState(() => isLoading = false);
                  }
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Cancellation'),
          content: const Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() => isLoading = true);
                _showLoadingDialog(context);
                final updatedBooking = Booking(
                  bookingId: bookingId,
                  userId: widget.booking.userId,
                  restaurantId: widget.booking.restaurantId,
                  timeSlot: widget.booking.timeSlot,
                  numberOfPeople: widget.booking.numberOfPeople,
                  specialRequests: widget.booking.specialRequests,
                  status: "Cancelled",
                );

                bookingProvider.updateBooking(updatedBooking).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking Cancelled')),
                  );
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetailsPage(
                        restaurant: widget.restaurant,
                        booking: updatedBooking,
                        isPastBooking: false,
                      ),
                    ),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to cancel booking')),
                  );
                }).whenComplete(() {
                  setState(() => isLoading = false);
                });
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
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

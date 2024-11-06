import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date and time formatting
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore
import 'package:jom_makan/models/booking.dart'; // Assuming you have a Booking model
import 'package:jom_makan/models/restaurant.dart'; // Assuming you have a Restaurant model

class AddBookingScreen extends StatefulWidget {
  final Restaurant restaurant;
  final String userId;

  AddBookingScreen({Key? key, required this.restaurant, required this.userId}) : super(key: key);

  @override
  _AddBookingScreenState createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  final TextEditingController _numberOfPeopleController = TextEditingController();
  final TextEditingController _specialRequestsController = TextEditingController();
  DateTime? _selectedDateTime;

  Future<void> _submitBooking() async {
    if (_numberOfPeopleController.text.isEmpty || _selectedDateTime == null) {
      // Show an error if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Create a Booking object
    final booking = Booking(
      bookingId: '', // Firestore will auto-generate an ID
      userId: widget.userId, // Replace with actual user ID
      restaurantId: widget.restaurant.id,
      numberOfPeople: int.parse(_numberOfPeopleController.text),
      timeSlot: Timestamp.fromDate(_selectedDateTime!),
      specialRequests: _specialRequestsController.text,
      status: "Pending", // Save approval status
    );

    // Save to Firestore
    await FirebaseFirestore.instance.collection('bookings').add(booking.toFirestore());

    // Navigate back or show a success message
    Navigator.pop(context);
  }

  void _selectDateTime(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      // Select time after date selection
      final timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );

      if (timePicked != null) {
        setState(() {
          _selectedDateTime = DateTime(picked.year, picked.month, picked.day, timePicked.hour, timePicked.minute);
        });
      }
    }
  }

  @override
  void dispose() {
    _numberOfPeopleController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Booking for ${widget.restaurant.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _numberOfPeopleController,
              decoration: InputDecoration(
                labelText: 'Number of People',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _specialRequestsController,
              decoration: InputDecoration(
                labelText: 'Special Requests (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _selectDateTime(context),
              child: Text(_selectedDateTime == null
                  ? 'Select Date & Time'
                  : 'Selected: ${DateFormat.yMMMd().add_jm().format(_selectedDateTime!)}'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitBooking,
              child: Text('Submit Booking'),
            ),
          ],
        ),
      ),
    );
  }
}

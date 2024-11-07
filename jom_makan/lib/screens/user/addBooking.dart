import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date and time formatting
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore
import 'package:jom_makan/models/booking.dart'; // Assuming you have a Booking model
import 'package:jom_makan/models/restaurant.dart'; // Assuming you have a Restaurant model

class AddBookingScreen extends StatefulWidget {
  final Restaurant restaurant;
  final String userId;

  const AddBookingScreen(
      {super.key, required this.restaurant, required this.userId});

  @override
  _AddBookingScreenState createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  final TextEditingController _numberOfPeopleController =
      TextEditingController();
  final TextEditingController _specialRequestsController =
      TextEditingController();
  DateTime? _selectedDateTime;

  Future<void> _submitBooking() async {
    if (_numberOfPeopleController.text.isEmpty || _selectedDateTime == null) {
      // Show an error if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
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
    await FirebaseFirestore.instance
        .collection('bookings')
        .add(booking.toFirestore());

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
          _selectedDateTime = DateTime(picked.year, picked.month, picked.day,
              timePicked.hour, timePicked.minute);
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.restaurant.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 8),
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
                      child: const Center(child: Text('No Image Available')),
                    ),
              const SizedBox(height: 16),
              TextField(
                controller: _numberOfPeopleController,
                decoration: InputDecoration(
                  labelText: 'Number of People',
                  labelStyle: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(Icons.group, color: Colors.blueAccent),
                  filled: true,
                  fillColor: Colors.grey[200], // Light background color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide.none, // No border line for a cleaner look
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.blueAccent, width: 1.5),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _specialRequestsController,
                decoration: InputDecoration(
                  labelText: 'Special Requests (optional)',
                  labelStyle: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(Icons.message, color: Colors.blueAccent),
                  filled: true,
                  fillColor: Colors.grey[200], // Light background color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.blueAccent, width: 1.5),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _selectDateTime(context),
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _selectedDateTime == null
                      ? 'Select Date & Time'
                      : 'Selected: ${DateFormat.yMMMd().add_jm().format(_selectedDateTime!)}',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  side: BorderSide(
                    color: Colors.grey[400]!,
                    width: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitBooking,
                child: const Text('Submit Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

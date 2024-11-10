import 'package:flutter/material.dart';
import 'package:jom_makan/models/booking.dart';
import 'package:jom_makan/providers/booking_provider.dart';
import 'package:provider/provider.dart';
// import 'package:jom_makan/widgets/restaurant/custom_bottom_navigation.dart';

class ManageBooking extends StatefulWidget {
  final String restaurantId;

  const ManageBooking({super.key, required this.restaurantId});

  @override
  _ManageBookingState createState() => _ManageBookingState();
}

class _ManageBookingState extends State<ManageBooking> {
  // int _selectedIndex = 0; // For tracking the selected tab in the bottom navigation
  String _selectedCategory = 'Pending'; // Default category to display
  ScrollController _scrollController = ScrollController(); // Controller for horizontal scroll

  @override
  void initState() {
    super.initState();
    // Fetch bookings when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false)
          .fetchBookingsByRestaurant(widget.restaurantId);
    });
  }

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });

  //   // Handle navigation based on the selected index
  //   // You can add more cases if the bottom bar should navigate to other pages.
  //   if (index == 0) {
  //     Navigator.pushNamed(context, '/restaurantHome');
  //   } else if (index == 1) {
  //     // Handle other navigation logic
  //   }
  // }

  // Method to change the selected category
  void _changeCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    // Get bookings categorized by status
    List<Booking> pendingBookings = bookingProvider.bookings
        .where((booking) => booking.status == 'Pending')
        .toList();
    List<Booking> approvedBookings = bookingProvider.bookings
        .where((booking) => booking.status == 'Approved')
        .toList();
    List<Booking> rejectedBookings = bookingProvider.bookings
        .where((booking) => booking.status == 'Rejected')
        .toList();
    List<Booking> completedBookings = bookingProvider.bookings
        .where((booking) => booking.status == 'Completed')
        .toList();
      List<Booking> cancelledBookings = bookingProvider.bookings
        .where((booking) => booking.status == 'Cancelled')
        .toList();

    // Filter bookings based on the selected category
    List<Booking> displayedBookings = [];
    if (_selectedCategory == 'Pending') {
      displayedBookings = pendingBookings;
    } else if (_selectedCategory == 'Approved') {
      displayedBookings = approvedBookings;
    } else if (_selectedCategory == 'Rejected') {
      displayedBookings = rejectedBookings;
    } else if (_selectedCategory == 'Completed') {
      displayedBookings = completedBookings;
    } else if (_selectedCategory == 'Cancelled') {
      displayedBookings = cancelledBookings;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        backgroundColor: Colors.blue[100],
      ),
      body: bookingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category buttons with arrows
                    Stack(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => _changeCategory('Pending'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedCategory == 'Pending' ? Colors.yellow[300] : Colors.grey,
                                  foregroundColor: _selectedCategory == 'Pending' ? Colors.black : Colors.white, // Text color
                                ),
                                child: const Text('Pending'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => _changeCategory('Approved'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedCategory == 'Approved' ? Colors.blue[300] : Colors.grey,
                                  foregroundColor: _selectedCategory == 'Approved' ? Colors.black : Colors.white, // Text color
                                ),
                                child: const Text('Approved'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => _changeCategory('Rejected'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedCategory == 'Rejected' ? Colors.red[300] : Colors.grey,
                                  foregroundColor: _selectedCategory == 'Rejected' ? Colors.black : Colors.white, // Text color
                                ),
                                child: const Text('Rejected'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => _changeCategory('Completed'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedCategory == 'Completed' ? Colors.green[300] : Colors.grey,
                                  foregroundColor: _selectedCategory == 'Completed' ? Colors.black : Colors.white, // Text color
                                ),
                                child: const Text('Completed'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => _changeCategory('Cancelled'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedCategory == 'Cancelled' ? Colors.purple[300] : Colors.grey,
                                  foregroundColor: _selectedCategory == 'Cancelled' ? Colors.black : Colors.white, // Text color
                                ),
                                child: const Text('Cancelled'),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                        // Left Arrow Icon
                        Positioned(
                          left: -20,
                          top: 0,
                          bottom: 0,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_left, color: Colors.black),
                            onPressed: () {
                              _scrollController.animateTo(
                                _scrollController.position.pixels - 100,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                        // Right Arrow Icon
                        Positioned(
                          right: -20,
                          top: 0,
                          bottom: 0,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_right, color: Colors.black),
                            onPressed: () {
                              _scrollController.animateTo(
                                _scrollController.position.pixels + 100,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Display bookings based on selected category
                    _buildSection(
                      context,
                      'Bookings - ${_selectedCategory}',
                      displayedBookings,
                      onApprove: (Booking booking) {
                        bookingProvider.updateBookingStatus(booking, 'Approved');
                      },
                      onReject: (Booking booking) {
                        bookingProvider.updateBookingStatus(booking, 'Rejected');
                      },
                      onComplete: (Booking booking) {
                        bookingProvider.updateBookingStatus(booking, 'Completed');
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper method to build a section with optional actions
  Widget _buildSection(
    BuildContext context,
    String title,
    List<Booking> bookings, {
    Function(Booking)? onApprove,
    Function(Booking)? onReject,
    Function(Booking)? onComplete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        bookings.isEmpty
            ? const Text('No bookings available')
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  Booking booking = bookings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Booking ID: ${booking.bookingId}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Number of People: ${booking.numberOfPeople}'),
                          Text('Time Slot: ${booking.timeSlot.toDate()}'),
                          Text('Status: ${booking.status}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // For 'Pending' bookings, show approve/reject
                          if (booking.status == 'Pending') ...[
                            if (onApprove != null)
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () => onApprove(booking),
                              ),
                            if (onReject != null)
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => onReject(booking),
                              ),
                          ],
                          // For 'Approved' bookings, show complete
                          if (booking.status == 'Approved') ...[
                            if (onComplete != null)
                              IconButton(
                                icon: const Icon(Icons.done, color: Colors.blue),
                                onPressed: () => onComplete(booking),
                              ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}

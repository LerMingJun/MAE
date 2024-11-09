import 'package:flutter/material.dart';
import 'package:jom_makan/providers/booking_provider.dart';
import 'package:jom_makan/providers/review_provider.dart';
import 'package:jom_makan/widgets/custom_loading.dart';  // Default CustomLoading
import 'package:provider/provider.dart';
class ReportPage extends StatelessWidget {
  final String restaurantId;

  ReportPage({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    // Fetch bookings and reviews initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchBookingsByRestaurant(restaurantId);
      Provider.of<ReviewProvider>(context, listen: false).fetchReviews(restaurantId);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Page"),
        backgroundColor: Colors.teal,
      ),
      body: Consumer2<BookingProvider, ReviewProvider>(
        builder: (context, bookingProvider, reviewProvider, _) {
          // Check if either booking or review data is still loading
          if (bookingProvider.isLoading || reviewProvider.isLoading) {
            return const CustomLoading(text: 'Loading',);  // Use the default CustomLoading
          }

          final bookings = bookingProvider.bookings;
          int totalBookings = bookings.length;
          int pendingCount = bookings.where((b) => b.status == "Pending").length;
          int approvedCount = bookings.where((b) => b.status == "Approved").length;
          int completedCount = bookings.where((b) => b.status == "Completed").length;
          int rejectedCount = bookings.where((b) => b.status == "Rejected").length;
          int cancelledCount = bookings.where((b) => b.status == "Cancelled").length;

          final reviews = reviewProvider.reviews;
          int totalReviews = reviews.length;
          double averageRating = reviewProvider.calculateAverageRating(reviews);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Booking Report",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 20),

                // Booking summary cards
                Column(
                  children: [
                    _buildSummaryCard("Total Bookings", totalBookings, Colors.blueGrey, Icons.book_online),
                    const SizedBox(height: 16),
                    _buildStatusCard("Pending", pendingCount, Colors.orange, Icons.pending_actions),
                    _buildStatusCard("Approved", approvedCount, Colors.green, Icons.check_circle),
                    _buildStatusCard("Completed", completedCount, Colors.blue, Icons.done_all),
                    _buildStatusCard("Rejected", rejectedCount, Colors.red, Icons.cancel),
                    _buildStatusCard("Cancelled", cancelledCount, Colors.grey, Icons.remove_circle),
                  ],
                ),
                const SizedBox(height: 20),

                const Text(
                  "Review Report",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 20),

                // Review summary cards
                Column(
                  children: [
                    _buildSummaryCard("Total Reviews", totalReviews, Colors.blue, Icons.rate_review),
                    const SizedBox(height: 16),
                    _buildSummaryCard("Average Rating", averageRating.toStringAsFixed(1), Colors.green, Icons.star),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String label, dynamic count, Color color, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold)),
                Text(count.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String label, int count, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          count.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

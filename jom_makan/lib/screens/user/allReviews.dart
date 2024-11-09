import 'package:flutter/material.dart';
import 'package:jom_makan/constants/placeholderURL.dart';
import 'package:jom_makan/models/user.dart';
import 'package:jom_makan/providers/review_provider.dart';
import 'package:provider/provider.dart';

class AllReviewsScreen extends StatelessWidget {
  final String restaurantId;
  final User? user;

  const AllReviewsScreen(
      {super.key, required this.restaurantId, required this.user});

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);

    // Fetch the reviews if not already done
    if (!reviewProvider.isLoading) {
      reviewProvider.fetchReviews(restaurantId);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Reviews"),
      ),
      body: reviewProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reviewProvider.reviews.isEmpty
              ? const Center(
                  child: Text(
                    'No reviews available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: reviewProvider.reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviewProvider.reviews[index];
                    return _buildReviewCard(
                      user?.username ?? 'Anonymous',
                      review.feedback,
                      review.rating,
                      review.timestamp.toDate(),
                      user?.profileImage ?? userPlaceholder,
                    );
                  },
                ),
    );
  }

  Widget _buildReviewCard(String userName, String feedback, double rating,
      DateTime date, String userProfileImage) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      NetworkImage(userProfileImage),
                ),
                const SizedBox(width: 8),
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  "${date.difference(DateTime.now()).inDays.abs()} days ago",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (starIndex) => Icon(
                  starIndex < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              feedback,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

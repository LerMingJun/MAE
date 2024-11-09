import 'package:flutter/material.dart';
import 'package:jom_makan/constants/placeholderURL.dart';
import 'package:jom_makan/models/review.dart';
import 'package:jom_makan/models/user.dart';
import 'package:jom_makan/providers/review_provider.dart';
import 'package:provider/provider.dart';

class AllReviewsScreen extends StatefulWidget {
  final String restaurantId;
  final User? user;

  const AllReviewsScreen(
      {super.key, required this.restaurantId, required this.user});

  @override
  _AllReviewsScreenState createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  bool _showUserReviewsOnly = false;

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);

    // Fetch the reviews if not already done
    if (!reviewProvider.isLoading) {
      reviewProvider.fetchAllReviews(widget.restaurantId);
    }

    // Filter the reviews based on the filter toggle
    final reviewsToDisplay = _showUserReviewsOnly
        ? reviewProvider.reviews
            .where((review) => review.userId == widget.user?.userID)
            .toList()
        : reviewProvider.reviews;

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Reviews"),
        actions: [
          IconButton(
            icon: Icon(
              _showUserReviewsOnly ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() {
                _showUserReviewsOnly = !_showUserReviewsOnly;
              });
            },
          ),
        ],
      ),
      body: reviewProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reviewsToDisplay.isEmpty
              ? const Center(
                  child: Text(
                    'No reviews available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: reviewsToDisplay.length,
                  itemBuilder: (context, index) {
                    final review = reviewsToDisplay[index];
                    return _buildReviewCard(
                      widget.user?.username ?? 'Anonymous',
                      review.feedback,
                      review.rating,
                      review.timestamp.toDate(),
                      widget.user?.profileImage ?? userPlaceholder,
                      review.userId == widget.user?.userID,
                      review,
                    );
                  },
                ),
    );
  }

  Widget _buildReviewCard(
      String userName,
      String feedback,
      double rating,
      DateTime date,
      String userProfileImage,
      bool isUserReview,
      Review review) {
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
                  backgroundImage: NetworkImage(userProfileImage),
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
                if (isUserReview) ...[
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      // Show a confirmation dialog before deleting
                      bool? confirmDelete = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: const Text(
                              'Are you sure you want to delete this review?',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(false); // User cancels
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(true); // User confirms
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete == true) {
                        // Proceed with deletion if user confirms
                        final reviewProvider =
                            Provider.of<ReviewProvider>(context, listen: false);

                        bool success =
                            await reviewProvider.deleteReview(review.reviewId);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Review deleted successfully')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to delete review')),
                          );
                        }
                      }
                    },
                  ),
                ],
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

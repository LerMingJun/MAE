import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jom_makan/constants/placeholderURL.dart';
import 'package:jom_makan/models/reply.dart';
import 'package:jom_makan/models/review.dart';
import 'package:jom_makan/models/user.dart';
import 'package:jom_makan/providers/reply_provider.dart';
import 'package:jom_makan/providers/review_provider.dart';
import 'package:provider/provider.dart';

class AllReviewsScreen extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  final User? user;

  const AllReviewsScreen(
      {super.key,
      required this.restaurantId,
      required this.user,
      required this.restaurantName});

  @override
  _AllReviewsScreenState createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  bool _showUserReviewsOnly = false;
  Map<String, TextEditingController> _replyControllers =
      {}; // Map for controllers
  @override
  void initState() {
    super.initState();
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!reviewProvider.isLoading) {
        reviewProvider.fetchAllReviewsAndReplies(widget.restaurantId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);

    // If loading is true, show the loading indicator
    if (reviewProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("All Reviews"),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
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

                    // Initialize the controller for this review if not done yet
                    if (!_replyControllers.containsKey(review.reviewId)) {
                      _replyControllers[review.reviewId] =
                          TextEditingController();
                    }

                    return _buildReviewCard(
                        widget.user?.username ?? 'Anonymous',
                        review.feedback,
                        review.rating,
                        review.timestamp.toDate(),
                        widget.user?.profileImage ?? userPlaceholder,
                        true,
                        review,
                        widget.restaurantName);
                  },
                ),
    );
  }

  Future<User> _getUserById(String userId) async {
    final userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      return User.fromFirestore(
          userSnapshot); // Assuming `User` has a `fromFirestore` method.
    } else {
      throw Exception('User not found');
    }
  }

  Widget _buildReviewCard(
      String userName,
      String feedback,
      double rating,
      DateTime date,
      String userProfileImage,
      bool isUserReview,
      Review review,
      String restaurantName) {
    // Access the specific controller for this review
    final replyController = _replyControllers[review.reviewId]!;

    return FutureBuilder<User>(
      future: _getUserById(review.userId), // Fetch user data by userId
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Display loading indicator while fetching user data
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          User user = snapshot.data!;

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
                            NetworkImage(user.profileImage ?? userPlaceholder),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${date.difference(DateTime.now()).inDays.abs()} days ago",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
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
                                  Provider.of<ReviewProvider>(context,
                                      listen: false);

                              bool success = await reviewProvider
                                  .deleteReview(review.reviewId);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Review deleted successfully')),
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
                  Text(feedback, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),

                  // Display the replies below the review
                  if (review.replies.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: review.replies.length,
                      itemBuilder: (context, index) {
                        final reply = review.replies[index];
                        final replyAuthor = reply.userId == widget.user?.userID
                            ? widget.user?.username ?? 'You'
                            : restaurantName; // Assuming it's a restaurant reply for non-user replies
                        final replyDate = reply.timestamp.toDate();
                        return Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    replyAuthor,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "${replyDate.difference(DateTime.now()).inDays.abs()} days ago",
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      reply.replyText,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      // Delete reply logic
                                      await _deleteReply(reply);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Future<void> _deleteReply(Reply reply) async {
    try {
      // Call the provider to delete the reply
      final reviewProvider =
          Provider.of<ReviewProvider>(context, listen: false);
      final replyProvider = Provider.of<ReplyProvider>(context, listen: false);
      await replyProvider.deleteReply(reply.reviewId, reply.replyId);

      // Refresh the UI by calling setState
      setState(() {
        // After deletion, refresh the reviews list
        reviewProvider.fetchAllReviewsAndReplies(widget.restaurantId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete reply: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Clean up all controllers when the widget is disposed
    _replyControllers.values.forEach((controller) {
      controller.dispose();
    });
    super.dispose();
  }
}

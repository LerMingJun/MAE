import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jom_makan/models/reply.dart';
import 'package:jom_makan/models/review.dart';
import 'package:jom_makan/providers/review_provider.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/providers/reply_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:jom_makan/widgets/restaurant/custom_loading.dart';

class ReviewPage extends StatefulWidget {
  final String restaurantId;

  ReviewPage({required this.restaurantId});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int selectedRating = 0; // 0 means show all reviews
  Map<String, String> userNames = {}; // Store user names by userId
  TextEditingController replyController = TextEditingController();
  Map<String, TextEditingController> _replyControllers = {};
  Map<String, String> _editingReplies = {}; // Store editing reply IDs

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchReviewsAndUserNames();
    });
  }

  String formatTimestamp(Timestamp timestamp) {
    return DateFormat.yMMMd().format(timestamp.toDate());
  }

  Future<void> _fetchReviewsAndUserNames() async {
    await Provider.of<ReviewProvider>(context, listen: false)
        .fetchReviews(widget.restaurantId);

    final reviews = Provider.of<ReviewProvider>(context, listen: false).reviews;
    for (var review in reviews) {
      if (!userNames.containsKey(review.userId)) {
        await Provider.of<UserProvider>(context, listen: false)
            .fetchUserDatabyUid(review.userId);
        String userName = Provider.of<UserProvider>(context, listen: false)
                .userData?.username ?? 'Unknown';
        setState(() {
          userNames[review.userId] = userName;
        });
      }

      // Fetch replies for each review
      await Provider.of<ReplyProvider>(context, listen: false)
          .fetchRepliesForReview(review.reviewId);
    }
  }

  Future<void> _sendReply(String reviewId) async {
    String replyText = _replyControllers[reviewId]?.text.trim() ?? '';

    if (replyText.isNotEmpty) {
      CustomLoading.show(context);

      try {
        String replyId = FirebaseFirestore.instance.collection('replies').doc().id;
        Reply reply = Reply(
          replyId: replyId,
          reviewId: reviewId,
          restaurantId: widget.restaurantId,
          replyText: replyText,
          timestamp: Timestamp.now(),
        );

        await Provider.of<ReplyProvider>(context, listen: false)
            .addReplyToReview(reviewId, reply);

        _replyControllers[reviewId]?.clear();
      } catch (error) {
        print("Failed to send reply: $error");
      } finally {
        CustomLoading.hide(context);
      }
    }
  }

  Future<void> _editReply(String reviewId, String replyId) async {
    String replyText = _replyControllers[reviewId]?.text.trim() ?? '';

    if (replyText.isNotEmpty) {
      bool? shouldSave = await _showSaveConfirmationDialog();
      if (shouldSave ?? false) {
        CustomLoading.show(context);

        try {
          Reply updatedReply = Reply(
            replyId: replyId,
            reviewId: reviewId,
            restaurantId: widget.restaurantId,
            replyText: replyText,
            timestamp: Timestamp.now(),
          );
          await Provider.of<ReplyProvider>(context, listen: false)
              .updateReply(reviewId, replyId, updatedReply);

          setState(() {
            _editingReplies.remove(reviewId); // Stop editing
          });
          _replyControllers[reviewId]?.clear();
        } catch (error) {
          print("Failed to update reply: $error");
        } finally {
          CustomLoading.hide(context);
        }
      }
    }
  }

  Future<void> _deleteReply(String reviewId, String replyId) async {
    // Show confirmation dialog before deletion
    bool? shouldDelete = await _showDeleteConfirmationDialog();
    if (shouldDelete ?? false) {
      CustomLoading.show(context);

      try {
        await Provider.of<ReplyProvider>(context, listen: false)
            .deleteReply(reviewId, replyId);
      } catch (error) {
        print("Failed to delete reply: $error");
      } finally {
        CustomLoading.hide(context);
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this reply?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showSaveConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Save'),
          content: const Text('Are you sure you want to save the changes?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    replyController.dispose();
    _replyControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews Page'),
        backgroundColor: Color.fromARGB(255, 91, 192, 187),
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, reviewProvider, _) {
          if (reviewProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reviewProvider.reviews.isEmpty) {
            return const Center(
              child: Text(
                'No reviews available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          List<Review> filteredReviews = selectedRating == 0
              ? reviewProvider.reviews
              : reviewProvider.reviews
                  .where((review) => review.rating == selectedRating)
                  .toList();

          filteredReviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<int>(
                    value: selectedRating,
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedRating = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Filter by Rating',
                      labelStyle: TextStyle(
                        color: Colors.teal,
                        fontSize: 16,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 0, child: Text('All Ratings')),
                      for (int i = 1; i <= 5; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              SizedBox(width: 8),
                              Text('$i Star${i > 1 ? 's' : ''}'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredReviews.length,
                  itemBuilder: (context, index) {
                    Review review = filteredReviews[index];
                    String formattedDate = formatTimestamp(review.timestamp);
                    String userName = userNames[review.userId] ?? 'Loading...';

                    if (!_replyControllers.containsKey(review.reviewId)) {
                      _replyControllers[review.reviewId] = TextEditingController();
                    }

                    List<Reply> replies = Provider.of<ReplyProvider>(context)
                        .getRepliesForReview(review.reviewId);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: List.generate(
                                    review.rating.toInt(),
                                    (index) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              review.feedback,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            for (var reply in replies)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.reply,
                                      size: 20,
                                      color: Colors.teal,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (reply.restaurantId != null && reply.restaurantId!.isNotEmpty)
                                                ? 'Restaurant'
                                                : 'User',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 4), 
                                          Text(
                                            formatTimestamp(reply.timestamp), 
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            reply.replyText,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          // Edit/Delete buttons
                                          if (reply.restaurantId == widget.restaurantId)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.edit),
                                                  onPressed: () {
                                                    setState(() {
                                                      _editingReplies[review.reviewId] =
                                                          reply.replyId;
                                                      _replyControllers[review.reviewId]
                                                              ?.text =
                                                          reply.replyText;
                                                    });
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.delete),
                                                  onPressed: () async {
                                                    await _deleteReply(
                                                        review.reviewId,
                                                        reply.replyId);
                                                  },
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 12),
                            // Show the reply text field only if not editing
                            _editingReplies.containsKey(review.reviewId)
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _replyControllers[review.reviewId],
                                          decoration: InputDecoration(
                                            labelText: 'Edit your reply...',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.save),
                                        onPressed: () {
                                          _editReply(review.reviewId, _editingReplies[review.reviewId]!);
                                        },
                                      ),
                                    ],
                                  )
                                : TextField(
                                    controller: _replyControllers[review.reviewId],
                                    decoration: InputDecoration(
                                      labelText: 'Reply to this review...',
                                      border: OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.send),
                                        onPressed: () {
                                          _sendReply(review.reviewId);
                                        },
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

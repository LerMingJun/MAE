import 'package:flutter/material.dart';
import 'package:jom_makan/models/reply.dart';
import 'package:jom_makan/repositories/reply_repository.dart';

class ReplyProvider with ChangeNotifier {
  final ReplyRepository _replyRepository = ReplyRepository();
  Map<String, List<Reply>> _repliesByReviewId = {}; // Store replies by reviewId
  bool _isLoading = false;

  List<Reply> getRepliesForReview(String reviewId) => _repliesByReviewId[reviewId] ?? [];
  bool get isLoading => _isLoading;

  // Fetch replies for a specific review
  Future<void> fetchRepliesForReview(String reviewId) async {
    if (_isLoading) return; // Prevent multiple fetch calls

    _isLoading = true;
    notifyListeners();

    try {
      final replies = await _replyRepository.fetchRepliesForReview(reviewId);
      _repliesByReviewId[reviewId] = replies; // Store replies for the specific reviewId
      print('Fetched ${replies.length} replies for review: $reviewId');
    } catch (e) {
      print('Error fetching replies: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new reply to a review
  Future<void> addReplyToReview(String reviewId, Reply reply) async {
    await _replyRepository.addReplyToReview(reviewId, reply);
    await fetchRepliesForReview(reviewId); // Refresh replies for that review after adding
  }

    // Edit an existing reply
  Future<void> updateReply(String reviewId, String replyId, Reply updatedReply) async {
    try {
      await _replyRepository.updateReply(reviewId, replyId, updatedReply);
      await fetchRepliesForReview(reviewId); // Refresh replies after editing
    } catch (e) {
      print('Error editing reply: $e');
    }
  }

  // Delete a reply
  Future<void> deleteReply(String reviewId, String replyId) async {
    try {
      await _replyRepository.deleteReply(reviewId, replyId);
      await fetchRepliesForReview(reviewId); // Refresh replies after deleting
    } catch (e) {
      print('Error deleting reply: $e');
    }
  }
}

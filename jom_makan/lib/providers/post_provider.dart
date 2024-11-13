import 'package:flutter/material.dart';
import 'package:jom_makan/models/post.dart';
import 'package:jom_makan/repositories/auth_repository.dart';
import 'package:jom_makan/repositories/post_repository.dart';
import 'package:jom_makan/repositories/user_repository.dart';
import 'package:image_picker/image_picker.dart';

class PostProvider with ChangeNotifier {
  final PostRepository _postRepository = PostRepository();
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();

  bool _isLoading = false;
  bool isAddingPost = false;
  List<Post>? _posts;
  List<Post>? _postsByUserID;
  Post? _userPost;

  Post? get userPost => _userPost;
  List<Post>? get posts => _posts;
  List<Post>? get postsByUserID => _postsByUserID;
  bool get isLoading => _isLoading;

  Future<void> addPost(XFile? imageFile, String title, String description,
      List<String> tags) async {
    isAddingPost = true;
    notifyListeners();

    try {
      await _postRepository.addPost(_authRepository.currentUser!.uid, imageFile,
          title, description, tags);
      await fetchAllPosts();
    } catch (e) {
      isAddingPost = false;
      notifyListeners();
      print('Error in PostProvider: $e');
      throw Exception('Error adding post');
    }

    isAddingPost = false;
    notifyListeners();
  }

  Future<void> updatePost(String postID, XFile? imageFile, String title,
      String description, List<String> tags) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _postRepository.editPost(
          postID, imageFile, title, description, tags);
      await fetchAllPosts();
      await fetchAllPostsByUserID();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error in PostProvider: $e');
      throw Exception('Error updating post');
    }
  }

  Future<void> fetchAllPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _posts = await _postRepository.fetchAllPosts();
    } catch (e) {
      _posts = [];
      print('Error in PostProvider: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllPostsByUserID() async {
    _isLoading = true;
    notifyListeners();

    try {
      _postsByUserID = await _postRepository
          .fetchAllPostsByUserID(_authRepository.currentUser!.uid);
    } catch (e) {
      _postsByUserID = [];
      print('Error in PostProvider: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Post?> fetchPostByPostID(String postID) async {
    try {
      _userPost = await _postRepository.fetchPostByPostID(postID);
      return _userPost;
    } catch (e) {
      _userPost = null;
      print('Error in PostProvider: $e');
    }
    return null;
  }

  Future<void> deletePost(String postID) async {
    try {
      await _postRepository.deletePost(postID);
      await fetchAllPostsByUserID();
    } catch (e) {
      print('Error in PostProvider: $e');
    }
  }

  Future<void> likePost(String postID, String? userID) async {
    await _postRepository.likePost(postID, userID!);
    // Directly update the like status of the post in the provider
    _posts?.forEach((post) {
      if (post.postId == postID) {
        post.likes.add(userID); // Add the current user's UID to the likes list
      }
    });
    await fetchAllPosts(); // You may still want to refetch posts to sync data
    notifyListeners(); // Notify listeners to update the UI
  }

  Future<void> unlikePost(String postID, String? userID) async {
    await _postRepository.unlikePost(postID, userID!);
    // Directly update the like status of the post in the provider
    _posts?.forEach((post) {
      if (post.postId == postID) {
        post.likes.remove(userID); // Remove the current user's UID from the likes list
      }
    });
    await fetchAllPosts(); // You may still want to refetch posts to sync data
    notifyListeners(); // Notify listeners to update the UI
  }

  Future<List<Post>> searchPosts(String query) async {
    // Fetch all posts if not already fetched
    if (_posts == null) {
      await fetchAllPosts();
    }

    if (query.isEmpty) {
      return _posts ?? []; // Return all posts if the query is empty
    }

    // Filter posts based on the title or description
    return _posts?.where((post) {
          return post.title.toLowerCase().contains(query.toLowerCase()) ||
              post.description.toLowerCase().contains(query.toLowerCase());
        }).toList() ??
        [];
  }
}

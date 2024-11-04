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
  List<Post>? _posts;
  List<Post>? _postsByUserID;
  Post? _userPost;

  Post? get userPost => _userPost;
  List<Post>? get posts => _posts;
  List<Post>? get postsByUserID => _postsByUserID;
  bool get isLoading => _isLoading;

  Future<void> addPost(XFile? imageFile, String title, String description,
      String activityID, String activityName) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _postRepository.addPost(_authRepository.currentUser!.uid, imageFile,
          title, description, activityID, activityName);
      //await fetchBookmarksAndProjects(); // Refresh the bookmarks list
      await fetchAllPosts();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error in PostProvider: $e');
      throw Exception('Error adding post');
    }
  }

  Future<void> updatePost(String postID, XFile? imageFile, String title, String description,
      String activityID, String activityName) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _postRepository.editPost(postID, imageFile,
          title, description, activityID, activityName, _authRepository.currentUser!.uid);

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
      _userPost = await _postRepository.fetchPostByPostID(_authRepository.currentUser!.uid, postID);
      return _userPost;
    } catch (e) {
      _userPost = null;

      print('Error in PostProvider: $e');
    }
    return null;
  }

  Future<void> deletePost(String postID) async {
    
    try {
      await _postRepository.deletePost(_authRepository.currentUser!.uid, postID);
      await fetchAllPostsByUserID();
    } catch (e) {
      print('Error in PostProvider: $e');
    }

  }

  Future<void> likePost(String postID) async {
    await _postRepository.likePost(postID, _authRepository.currentUser!.uid);
    await _userRepository.getUserData(_authRepository.currentUser!.uid);
    _updatePostLikes(postID, _authRepository.currentUser!.uid, true);
  }

  Future<void> unlikePost(String postID) async {
    await _postRepository.unlikePost(postID, _authRepository.currentUser!.uid);
    await _userRepository.getUserData(_authRepository.currentUser!.uid);
    _updatePostLikes(postID, _authRepository.currentUser!.uid, false);
  }

  void _updatePostLikes(String postID, String userID, bool liked) {
    Post? post = _posts?.firstWhere((post) => post.postID == postID);
    if (post != null) {
      if (liked) {
        post.likes.add(userID);
      } else {
        post.likes.remove(userID);
      }
      notifyListeners();
    }
  }

  
}

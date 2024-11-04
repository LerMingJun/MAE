import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jom_makan/models/bookmark.dart';
import 'package:jom_makan/models/project.dart';
import 'package:jom_makan/models/speech.dart';
import 'package:jom_makan/repositories/auth_repository.dart';
import 'package:jom_makan/repositories/bookmark_repository.dart';

class BookmarkProvider with ChangeNotifier {
  final BookmarkRepository _bookmarkRepository = BookmarkRepository();
  final AuthRepository _authRepository = AuthRepository();

  List<Bookmark> _bookmarks = [];
  List<Bookmark> _events = [];
  List<Bookmark> _speeches = [];
  bool _isLoading = false;
  bool _isRemoveDone = false;

  List<Bookmark> get bookmarks => _bookmarks;
  List<Bookmark> get events => _events;
  List<Bookmark> get speeches => _speeches;
  bool get isLoading => _isLoading;
  bool get isRemoveDone => _isRemoveDone;

  Future<void> addProjectBookmark(String projectID,String type, String title, String image, String location, Timestamp hostDate) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _bookmarkRepository.addBookmark(
          _authRepository.currentUser!.uid, projectID, type, title, image, location, hostDate);
      await fetchBookmarksAndProjects(); // Refresh the bookmarks list
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error in BookmarkProvider: $e');
      throw Exception('Error adding bookmark');
    }
  }

  Future<void> addSpeechBookmark(String speechID,String type, String title, String image, String location, Timestamp hostDate) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _bookmarkRepository.addBookmark(
          _authRepository.currentUser!.uid, speechID, type, title, image, location, hostDate);
      await fetchBookmarksAndSpeeches(); // Refresh the bookmarks list
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error in BookmarkProvider: $e');
      throw Exception('Error adding bookmark');
    }
  }

  Future<void> removeProjectBookmark(String projectID) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _bookmarkRepository.removeBookmark(
          _authRepository.currentUser!.uid, projectID);
      await fetchBookmarksAndProjects();
    } catch (e) {
      print('Error in BookmarkProvider: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeSpeechBookmark(String speechID) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _bookmarkRepository.removeBookmark(
          _authRepository.currentUser!.uid, speechID);
      await fetchBookmarksAndSpeeches();
    } catch (e) {
      print('Error in BookmarkProvider: $e');
    }

    _isLoading = false;
    notifyListeners();
  }


  Future<void> fetchBookmarksAndProjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      List<Bookmark> bookmarks = await _bookmarkRepository
          .fetchBookmarksByUserID(_authRepository.currentUser!.uid);

      // Fetch events using the eventIDs from the bookmarks
      List<Bookmark> fetchedEvents = [];
      for (var bookmark in bookmarks) {
        if (bookmark.type == 'project') {
          
          fetchedEvents.add(bookmark);
        }
      }

      _events = fetchedEvents;
    } catch (e) {
      print('Error fetching bookmarks and events1: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBookmarksAndSpeeches() async {
    _isLoading = true;
    notifyListeners();

    try {
      List<Bookmark> bookmarks = await _bookmarkRepository
          .fetchBookmarksByUserID(_authRepository.currentUser!.uid);

      // Fetch events using the eventIDs from the bookmarks
      List<Bookmark> fetchedSpeeches = [];

      for (var bookmark in bookmarks) {
        if (bookmark.type == 'speech') {
         
          fetchedSpeeches.add(bookmark);
        }
      }

      _speeches = fetchedSpeeches;
    } catch (e) {
      print('Error fetching bookmarks and events2: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> isProjectBookmarked(String projectID) async {
    return await _bookmarkRepository.isActivityBookmarked(
        _authRepository.currentUser!.uid, projectID);
  }

  Future<bool> isSpeechBookmarked(String speechID) async {
    return await _bookmarkRepository.isActivityBookmarked(
        _authRepository.currentUser!.uid, speechID);
  }
}

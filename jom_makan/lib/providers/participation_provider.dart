import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jom_makan/models/participation.dart';
import 'package:jom_makan/models/project.dart';
import 'package:jom_makan/models/speech.dart';
import 'package:jom_makan/repositories/auth_repository.dart';
import 'package:jom_makan/repositories/participation_repository.dart';
import 'package:table_calendar/table_calendar.dart';

class ParticipationProvider with ChangeNotifier {
  final ParticipationRepository _participationRepository = ParticipationRepository();
  final AuthRepository _authRepository = AuthRepository();

  List<Participation> _participations = [];
  List<Event> _events = [];
  List<Speech> _speeches = [];
  List<Participation>? _allUserActivities = [];
  List<Participation> _pastActivities = [];
  
  bool _isLoading = false;

  List<Participation> get participation => _participations;
  List<Event> get events => _events;
  List<Speech> get speeches => _speeches;
  
  List<Participation>? get allUserActivities => _allUserActivities;
  List<Participation> get pastActivities => _pastActivities;
  bool get isLoading => _isLoading;

  Future<void> joinActivity(String activityID, String image, Timestamp hostDate, String location, String title, String type, int impoints, String organizerID) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _participationRepository.joinActivity(
          _authRepository.currentUser!.uid, activityID, image, hostDate, location, title, type, impoints, organizerID);
      //await fetchBookmarksAndProjects(); // Refresh the bookmarks list
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error in ParticipationProvider: $e');
      throw Exception('Error adding participation');
    }
  }


  Future<void> leaveActivity(String activityID, String type, int impoints) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _participationRepository.leaveActivity(
          _authRepository.currentUser!.uid, activityID, type, impoints);
      //await fetchBookmarksAndProjects();
    } catch (e) {
      print('Error in ParticipationProvider: $e');
      throw Exception('Error removing participation');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllActivitiesByUserID() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allUserActivities  = await _participationRepository.fetchAllActivitiesByUserID(_authRepository.currentUser!.uid);
      

    } catch (e) {
      _allUserActivities = [];
      print('Error in EventProvider: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPastParticipatedActivities() async {
     _isLoading = true;
     notifyListeners();

    try {
      _pastActivities = await _participationRepository.fetchPastParticipatedActivities(_authRepository.currentUser!.uid);
    } catch (e) {
      _pastActivities = [];
      print('Error in EventProvider: $e');
    }
     _isLoading = false;
     notifyListeners();
  }

  List<Participation> getEventsForDay(DateTime day) {
    return _allUserActivities!.where((activity) => isSameDay(activity.hostDate.toDate(), day)).toList();
  }
  

}

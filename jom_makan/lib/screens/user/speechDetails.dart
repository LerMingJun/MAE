import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jom_makan/models/speech.dart';
import 'package:jom_makan/providers/bookmark_provider.dart';

import 'package:jom_makan/providers/event_provider.dart';
import 'package:jom_makan/providers/speech_provider.dart';

import 'package:jom_makan/widgets/custom_details.dart';
import 'package:jom_makan/widgets/custom_loading.dart';

import 'package:provider/provider.dart';

class SpeechDetail extends StatefulWidget {
  const SpeechDetail({super.key});

  @override
  State<SpeechDetail> createState() => _SpeechDetailState();
}

class _SpeechDetailState extends State<SpeechDetail> {
  late GoogleMapController mapController;
  //String? bookmarkID; // State variable to store bookmarkID
  bool isSaved = false;
  bool isJoined = false;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _toggleJoinStatus() async {
    setState(() {
      isJoined = !isJoined;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfBookmarkedAndJoined();
    });
  }

  Future<void> _checkIfBookmarkedAndJoined() async {
    final bookmarkProvider =
        Provider.of<BookmarkProvider>(context, listen: false);
    final String speechID =
        ModalRoute.of(context)!.settings.arguments as String;

    bool saved = await bookmarkProvider.isSpeechBookmarked(speechID); //

    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    bool joined = await eventProvider.isActivityJoined(speechID);

    setState(() {
      isSaved = saved;
      isJoined = joined;
    });
  }

  @override
  Widget build(BuildContext context) {
    final speechProvider = Provider.of<SpeechProvider>(context, listen: false);
    final String speechID =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body:
          //Text("hi")
          FutureBuilder<Speech?>(
        future: //postProvider.fetchPostByPostID(speechID),
            speechProvider.getSpeechByID(speechID),
        builder: (pageContext, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CustomLoading(text: 'Loading Details...'));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Speech not found'));
          } else {
            Speech speech = snapshot.data!;

            return CustomDetailScreen(
              id: speech.speechID,
              image: speech.image,
              tags: speech.tags,
              type: speech.type,
              title: speech.title,
              hoster: speech.organizer,
              hosterID: speech.organizerID,
              location: speech.location,
              hostDate: speech.hostDate,
              aboutDescription: speech.description,
              marker: speechProvider.marker,
              onMapCreated: _onMapCreated,
              center: speechProvider.center,
              onSaved: isSaved,
              onBookmarkToggle: () => _saveOrDeleteBookmark(
                  speechID,
                  speech.type,
                  speech.title,
                  speech.image,
                  speech.location,
                  speech.hostDate),
              recordingUrl: speech.recording ?? "",
              eventID: speech.eventID,
              eventTitle: speech.eventName,
              parentContext: pageContext,
              isJoined: isJoined,
              toggleJoinStatus: _toggleJoinStatus,
            );
          }
        },
      ),
    );
  }

  Future<void> _saveOrDeleteBookmark(String speechID, String type, String title,
      String image, String location, Timestamp hostDate) async {
    final bookmarkProvider =
        Provider.of<BookmarkProvider>(context, listen: false);

    if (!isSaved) {
      try {
        await bookmarkProvider.addSpeechBookmark(
            speechID, type, title, image, location, hostDate);
        setState(() {
          isSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to Bookmark!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error adding bookmark: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add bookmark'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      try {
        await bookmarkProvider.removeSpeechBookmark(speechID);
        setState(() {
          isSaved = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed Bookmark!'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        print('Error removing bookmark: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove bookmark'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

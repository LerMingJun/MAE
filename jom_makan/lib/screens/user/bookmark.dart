import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/providers/bookmark_provider.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_empty.dart';
import 'package:jom_makan/widgets/custom_lists.dart';
import 'package:jom_makan/widgets/custom_loading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Bookmark extends StatefulWidget {
  const Bookmark({super.key});

  @override
  State<Bookmark> createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookmarkProvider =
          Provider.of<BookmarkProvider>(context, listen: false);
      bookmarkProvider.fetchBookmarksAndProjects();
      bookmarkProvider.fetchBookmarksAndSpeeches();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: bookmarkProvider.isLoading
          ? Center(child: CustomLoading(text: 'Loading...'))
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'My ',
                            style: GoogleFonts.lato(fontSize: 24),
                          ),
                          TextSpan(
                            text: 'Bookmark',
                            style: GoogleFonts.lato(
                                fontSize: 24,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 38.0,
                      child: TabBar(
                        splashFactory: NoSplash.splashFactory,
                        dividerColor: Colors.transparent,
                        controller: _tabController,
                        indicator: UnderlineTabIndicator(
                          borderSide:
                              BorderSide(width: 2.0, color: AppColors.primary),
                        ),
                        labelColor: AppColors.primary,
                        unselectedLabelColor: Colors.black,
                        labelStyle: GoogleFonts.poppins(),
                        unselectedLabelStyle: GoogleFonts.poppins(),
                        tabs: [
                          Tab(
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Text('Projects'),
                            ),
                          ),
                          Tab(
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Text('Speech'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          ProjectContent(parentContext: context),
                          SpeechContent(parentContext: context)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class ProjectContent extends StatelessWidget {
  final BuildContext parentContext;

  const ProjectContent({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);

    return Column(
      children: [
        Expanded(
          child: bookmarkProvider.events.isEmpty
              ? SingleChildScrollView(
                child: EmptyWidget(
                    text: 'No Bookmark for Projects as of now.',
                    image: 'assets/no-bookmark.png'),
              )
              : ListView.builder(
                  itemCount: bookmarkProvider.events.length,
                  itemBuilder: (context, index) {
                    final bookmark = bookmarkProvider.events[index];
                    DateTime date = bookmark.hostDate.toDate();
                    String formattedDate = DateFormat('dd MMMM yyyy, HH:mm')
                        .format(date)
                        .toUpperCase();
                    return CustomList(
                      imageUrl: bookmark.image,
                      eventID: bookmark.activityID,
                      title: bookmark.title,
                      date: formattedDate,
                      image: bookmark.image,
                      onPressed: (context) async {
                        try {
                          await bookmarkProvider
                              .removeProjectBookmark(bookmark.activityID);
                          if (parentContext.mounted) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Removed Bookmark for the Project!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          print('Error removing bookmark: $e');
                          if (parentContext.mounted) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(
                                content: Text('Failed to remove bookmark'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class SpeechContent extends StatelessWidget {
  final BuildContext parentContext;

  const SpeechContent({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);

    return Column(
      children: [
        Expanded(
          child: bookmarkProvider.speeches.isEmpty
              ? SingleChildScrollView(
                child: EmptyWidget(
                    text: 'No Bookmark for Speeches as of now.',
                    image: 'assets/no-bookmark.png'),
              )
              : ListView.builder(
                  itemCount: bookmarkProvider.speeches.length,
                  itemBuilder: (context, index) {
                    final bookmark = bookmarkProvider.speeches[index];
                    DateTime date = bookmark.hostDate.toDate();
                    String formattedDate = DateFormat('dd MMMM yyyy, HH:mm')
                        .format(date)
                        .toUpperCase();
                    return CustomList(
                      imageUrl: bookmark.image,
                      speechID: bookmark.activityID,
                      title: bookmark.title,
                      date: formattedDate,
                      image: bookmark.image,
                      onPressed: (context) async {
                        try {
                          await bookmarkProvider
                              .removeSpeechBookmark(bookmark.activityID);
                          if (parentContext.mounted) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Removed Bookmark for the Speech!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          print('Error removing bookmark: $e');
                          if (parentContext.mounted) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(
                                content: Text('Failed to remove bookmark'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

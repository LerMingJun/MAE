import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:folks_app/models/participation.dart';
import 'package:folks_app/providers/participation_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:folks_app/api/articleAPI.dart';
import 'package:folks_app/constants/placeholderURL.dart';
import 'package:folks_app/models/article.dart';
import 'package:folks_app/providers/event_provider.dart';
import 'package:folks_app/providers/user_provider.dart';
import 'package:folks_app/theming/custom_themes.dart';
import 'package:folks_app/widgets/custom_cards.dart';
import 'package:folks_app/widgets/custom_loading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Article>> articles;
  @override
  void initState() {
    super.initState();
    // Fetch activities and articles when the widget is built
    articles = fetchArticles();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ParticipationProvider>(context, listen: false)
          .fetchAllActivitiesByUserID();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final participationProvider = Provider.of<ParticipationProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: participationProvider.isLoading
          ? Center(child: CustomLoading(text: 'Loading...'))
          : Stack(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.3,
                    //color: Color.fromRGBO(168, 234, 186, 100),
                    color: AppColors.tertiary),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2.0), // Border width
                                  decoration: BoxDecoration(
                                    color: AppColors.primary, // Border color
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                        userProvider.userData?.profileImage ??
                                            userPlaceholder),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Hello, ${userProvider.userData?.username ?? 'Unknown User'}!',
                                  style: GoogleFonts.lato(fontSize: 15),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/schedule');
                              },
                              icon: Icon(Icons.calendar_today_rounded),
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        // My Events Text
                        Text(
                          'My Activities',
                          style: GoogleFonts.lato(fontSize: 20),
                        ),
                        SizedBox(height: 16),
                        participationProvider.allUserActivities!.isEmpty
                            ? Card(
                                elevation: 7,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: AppColors.secondary,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/fist.png',
                                            height: 70,
                                            fit: BoxFit.cover,
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Hey, you have not participated in any activities yet!',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Be sure to check out the amazing activities in Folks!',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            :
                            // Horizontally scrollable cards
                            SizedBox(
                                height: 260,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: participationProvider
                                          .allUserActivities?.length ??
                                      0,
                                  itemBuilder: (context, index) {
                                    final activity = participationProvider
                                        .allUserActivities![index];
                                    return CustomHorizontalCard(
                                      imageUrl: activity.image,
                                      title: activity.title,
                                      location: activity.location,
                                      date1: activity.hostDate,
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context,
                                            activity.type == 'project'
                                                ? '/eventDetail'
                                                : '/speechDetail',
                                            arguments: activity.activityID);
                                      },
                                    );
                                  },
                                ),
                              ),
                        SizedBox(height: 10),
                        // Upcoming Opportunities Text

                        Text(
                          'SDG Related Articles',
                          style: GoogleFonts.lato(fontSize: 20),
                        ),

                        SizedBox(height: 20),
                        // Vertically scrollable cards
                        FutureBuilder<List<Article>>(
                          future: articles,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: SpinKitThreeBounce(
                                  color: AppColors.primary,
                                  size: 30.0,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(child: Text('No articles found'));
                            } else {
                              return Column(
                                children: snapshot.data!.take(5).map((article) {
                                  DateTime dateTime =
                                      DateTime.parse(article.date);
                                  String formattedDate =
                                      DateFormat('dd MMMM yyyy')
                                          .format(dateTime);

                                  return Card(
                                    margin: EdgeInsets.only(bottom: 20),
                                    elevation: 3,
                                    color: Colors.white,
                                    child: Container(
                                      child: InkWell(
                                        onTap: () async {
                                          Uri myURI = Uri.parse(article.url);
                                          if (!await launchUrl(myURI)) {
                                            throw Exception(
                                                'Could not launch $myURI');
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10))),
                                              child: Image.network(
                                                article.thumbnail,
                                                height: 130,
                                                width: 130,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  } else {
                                                    return CustomImageLoading(
                                                        width: 130);
                                                  }
                                                },
                                              ),
                                            ),
                                            //SizedBox(width: 10),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      article.title,
                                                      style: GoogleFonts.lato(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      article.excerpt,
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 10),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                    SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Image.network(
                                                          article
                                                              .publisherFavicon,
                                                          width: 20,
                                                          height: 20,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Image
                                                                .network(
                                                              userPlaceholder,
                                                              width: 20,
                                                              height: 20,
                                                              fit: BoxFit.cover,
                                                            );
                                                          },
                                                        ),
                                                        SizedBox(width: 2),
                                                        Expanded(
                                                          child: Text(
                                                            article
                                                                .publisherName,
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        10),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      '${formattedDate}',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 10),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

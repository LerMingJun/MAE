import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/providers/review_provider.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/screens/admins/mainpage.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/admins/custom_tab_bar.dart';
import 'package:jom_makan/widgets/custom_empty.dart';
import 'package:jom_makan/widgets/custom_loading.dart';
import 'package:provider/provider.dart';

class OverallAnalyticsScreen extends StatefulWidget {
  const OverallAnalyticsScreen({super.key});

  @override
  _OverallAnalyticsScreenState createState() => _OverallAnalyticsScreenState();
}

class _OverallAnalyticsScreenState extends State<OverallAnalyticsScreen> {
  Future<Map<String, dynamic>>? _analyticsData;

  @override

  void initState() {
    super.initState();
    _analyticsData = _fetchAnalyticsData();
  }

  Future<Map<String, dynamic>> _fetchAnalyticsData() async {
    // Fetch data from providers concurrently
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    // Fetch all required data
    await Future.wait([
      restaurantProvider.fetchAllRestaurants(),
      restaurantProvider.fetchUnapprovedRestaurants(),
      userProvider.fetchAllUsers(),
    ]);

    // Fetch the highest and lowest rated restaurants
    final ratingData =
        await reviewProvider.identifyHighestAndLowestRatedRestaurants();
    final topUsers = await userProvider.findTopUsers();

    return {
      'totalUsers': userProvider.totalUserCount,
      'totalPartners': restaurantProvider.totalRestaurantCount,
      'unapprovedPartners': restaurantProvider.unapprovedRestaurantCount,
      'highestRatingRestaurant': ratingData['highestRatingRestaurant'],
      'lowestRatingRestaurant': ratingData['lowestRatingRestaurant'],
      'topUserByPosts': topUsers['topUserByPosts'],
      'topUserByLikes': topUsers['topUserByLikes'],
      'maxPosts': topUsers['maxPosts'],
      'maxLikes': topUsers['maxLikes'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainPage()),
            );
          },
        ),
        title: Text(
          'Analytics',
          style: GoogleFonts.lato(
            fontSize: 24,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: double.infinity,
              height: 48.0,
              child: CustomTabBar(index: 0),
            ),
            const SizedBox(height: 16.0),

            // Center and add SingleChildScrollView to allow scrolling on overflow
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.8, // Adjust height to your preference
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _analyticsData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Center the loading indicator
                      return const Center(
                        child: CustomLoading(text: 'Fetching Analytics...'),
                      );
                    } else if (snapshot.hasError) {
                      // Show error state
                      return const Center(
                        child: Text('Error fetching analytics data'),
                      );
                    } else if (snapshot.hasData) {
                      // Show empty state if data is empty
                      if (snapshot.data!.isEmpty) {
                        return const Center(
                          child: EmptyWidget(
                            text: "No Analytics Found.\nPlease try again.",
                            image: 'assets/projectEmpty.png',
                          ),
                        );
                      }
                      // Display analytics cards if data exists with scrollable view
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            if (snapshot.data!['totalUsers'] != null)
                              _buildAnalyticsCard(
                                title: 'Total Users',
                                value: snapshot.data!['totalUsers'].toString(),
                                changeColor: Colors.green,
                              ),
                            if (snapshot.data!['totalPartners'] != null)
                              _buildAnalyticsCard(
                                title: 'Total Partners',
                                value:
                                    snapshot.data!['totalPartners'].toString(),
                                changeColor: Colors.green,
                              ),
                            if (snapshot.data!['unapprovedPartners'] != null)
                              _buildAnalyticsCard(
                                title: 'Unapproved Partners',
                                value: snapshot.data!['unapprovedPartners']
                                    .toString(),
                                changeColor: Colors.green,
                              ),
                            if (snapshot.data!['lowestRatingRestaurant'] !=
                                null)
                              _buildAnalyticsCard(
                                title: 'Lowest Rating Partner',
                                value: snapshot
                                            .data!['lowestRatingRestaurant'] !=
                                        null
                                    ? snapshot.data!['lowestRatingRestaurant']
                                        ['name']
                                    : 'N/A',
                                additionalInfo: snapshot
                                            .data!['lowestRatingRestaurant'] !=
                                        null
                                    ? 'Rating: ${snapshot.data!['lowestRatingRestaurant']['averageRating']}'
                                    : 'No ratings available',
                              ),
                            if (snapshot.data!['highestRatingRestaurant'] !=
                                null)
                              _buildAnalyticsCard(
                                title: 'Highest Rating Partner',
                                value: snapshot
                                            .data!['highestRatingRestaurant'] !=
                                        null
                                    ? snapshot.data!['highestRatingRestaurant']
                                        ['name']
                                    : 'N/A',
                                additionalInfo: snapshot
                                            .data!['highestRatingRestaurant'] !=
                                        null
                                    ? 'Rating: ${snapshot.data!['highestRatingRestaurant']['averageRating']}'
                                    : 'No ratings available',
                              ),
                            if (snapshot.data!['topUserByPosts'] != null)
                              _buildAnalyticsCard(
                                title: 'Top User by Posts',
                                value:
                                    snapshot.data!['topUserByPosts'] ?? 'N/A',
                                additionalInfo:
                                    snapshot.data!['topUserByPosts'] != null
                                        ? 'Posts: ${snapshot.data!['maxPosts']}'
                                        : 'No posts available',
                              ),
                            if (snapshot.data!['topUserByLikes'] != null)
                              _buildAnalyticsCard(
                                title: 'Top User by Likes',
                                value:
                                    snapshot.data!['topUserByLikes'] ?? 'N/A',
                                additionalInfo:
                                    snapshot.data!['topUserByLikes'] != null
                                        ? 'Likes: ${snapshot.data!['maxLikes']}'
                                        : 'No likes available',
                              ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox(); // Default return if none of the above conditions match
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create each analytics card
  Widget _buildAnalyticsCard({
    required String title,
    required String value,
    String? change,
    Color? changeColor,
    String? additionalInfo,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                if (change != null)
                  Text(
                    change,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: changeColor ?? Colors.black,
                    ),
                  ),
              ],
            ),
            if (additionalInfo != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  additionalInfo,
                  style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

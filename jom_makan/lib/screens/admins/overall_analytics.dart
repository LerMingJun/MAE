import 'package:flutter/material.dart';
import 'package:jom_makan/providers/review_provider.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/screens/admins/mainpage.dart';
import 'package:jom_makan/widgets/admins/custom_tab_bar.dart';
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
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    // Fetch all required data
    await Future.wait([
      restaurantProvider.fetchAllRestaurants(),
      restaurantProvider.fetchUnapprovedRestaurants(),
      userProvider.fetchAllUsers(),
    ]);

    // Fetch the highest and lowest rated restaurants
    final ratingData = await reviewProvider.identifyHighestAndLowestRatedRestaurants();

    return {
      'totalUsers': userProvider.totalUserCount,
      'totalPartners': restaurantProvider.totalRestaurantCount,
      'unapprovedPartners': restaurantProvider.unapprovedRestaurantCount,
      'highestRatingRestaurant': ratingData['highestRatingRestaurant'],
      'lowestRatingRestaurant': ratingData['lowestRatingRestaurant'],
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
        title: const Text('Analytics'),
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

            // Analytics Cards
            FutureBuilder<Map<String, dynamic>>(
              future: _analyticsData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show loading indicator
                } else if (snapshot.hasError) {
                  return const Text('Error fetching analytics data'); // Handle error
                } else if (snapshot.hasData) {
                  return Column(
                    children: [
                      _buildAnalyticsCard(
                        title: 'Total Users',
                        value: snapshot.data!['totalUsers'].toString(),
                        changeColor: Colors.green,
                      ),
                      _buildAnalyticsCard(
                        title: 'Total Partners',
                        value: snapshot.data!['totalPartners'].toString(),
                        changeColor: Colors.green,
                      ),
                      _buildAnalyticsCard(
                        title: 'Unapproved Partners',
                        value: snapshot.data!['unapprovedPartners'].toString(),
                        changeColor: Colors.green,
                      ),
                      _buildAnalyticsCard(
                        title: 'Lowest Rating Partner',
                        value: snapshot.data!['lowestRatingRestaurant'] != null 
                            ? snapshot.data!['lowestRatingRestaurant']['name'] 
                            : 'N/A',
                        additionalInfo: snapshot.data!['lowestRatingRestaurant'] != null 
                            ? 'Rating: ${snapshot.data!['lowestRatingRestaurant']['averageRating']}' 
                            : 'No ratings available',
                      ),
                      _buildAnalyticsCard(
                        title: 'Highest Rating Partner',
                        value: snapshot.data!['highestRatingRestaurant'] != null 
                            ? snapshot.data!['highestRatingRestaurant']['name'] 
                            : 'N/A',
                        additionalInfo: snapshot.data!['highestRatingRestaurant'] != null 
                            ? 'Rating: ${snapshot.data!['highestRatingRestaurant']['averageRating']}' 
                            : 'No ratings available',
                      ),
                    ],
                  );
                }
                return const SizedBox(); // Return an empty widget if none of the above
              },
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
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
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

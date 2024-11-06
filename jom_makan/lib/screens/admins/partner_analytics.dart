import 'package:flutter/material.dart';
import 'package:jom_makan/providers/review_provider.dart';
import 'package:jom_makan/screens/admins/mainpage.dart';
import 'package:jom_makan/widgets/admins/custom_tab_bar.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:provider/provider.dart';

class PartnerAnalyticsScreen extends StatefulWidget {
  const PartnerAnalyticsScreen({super.key});

  @override
  _PartnerAnalyticsScreen createState() => _PartnerAnalyticsScreen();
}

class _PartnerAnalyticsScreen extends State<PartnerAnalyticsScreen> {
  Future<Map<String, dynamic>>? _analyticsData;

  @override
  void initState() {
    super.initState();
    Provider.of<RestaurantProvider>(context, listen: false)
        .fetchAllRestaurants();
    Provider.of<RestaurantProvider>(context, listen: false)
        .fetchUnapprovedRestaurants();
    _analyticsData = Provider.of<ReviewProvider>(context, listen: false)
        .identifyHighestAndLowestRatedRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
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
            // Custom Tab Bar
            const SizedBox(
              width: double.infinity, // Take up the full width of the screen
              height: 48.0, // Specify a fixed height
              child: CustomTabBar(index: 1),
            ),
            const SizedBox(height: 16.0),

            // Analytics Cards
            _buildAnalyticsCard(
              title: 'Total Partners',
              value: restaurantProvider.totalRestaurantCount.toString(),
              changeColor: Colors.green,
            ),
            // _buildAnalyticsCard(
            //   title: 'Total Users',
            //   value: '500', // Replace with your data
            //   change: '▼ 10',
            //   changeColor: Colors.red,
            // ),
            // FutureBuilder to fetch and display highest and lowest rating partners
            _buildAnalyticsCard(
              title: 'Unapproved Partners',
              value: restaurantProvider.unapprovedRestaurantCount.toString(),
              changeColor: Colors.green,
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: _analyticsData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show loading indicator
                } else if (snapshot.hasError) {
                  return const Text('Error fetching ratings'); // Handle error
                } else if (snapshot.hasData) {
                  final highestRatingRestaurant =
                      snapshot.data!['highestRatingRestaurant'];
                  final lowestRatingRestaurant =
                      snapshot.data!['lowestRatingRestaurant'];

                  return Column(
                    children: [
                      _buildAnalyticsCard(
                        title: 'Lowest Rating Partner',
                        value: lowestRatingRestaurant != null
                            ? lowestRatingRestaurant['name']
                            : 'N/A',
                        additionalInfo: lowestRatingRestaurant != null
                            ? 'Rating: ${lowestRatingRestaurant['averageRating']}'
                            : 'No ratings available',
                      ),
                      _buildAnalyticsCard(
                        title: 'Highest Rating Partner',
                        value: highestRatingRestaurant != null
                            ? highestRatingRestaurant['name']
                            : 'N/A',
                        additionalInfo: highestRatingRestaurant != null
                            ? 'Rating: ${highestRatingRestaurant['averageRating']}'
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

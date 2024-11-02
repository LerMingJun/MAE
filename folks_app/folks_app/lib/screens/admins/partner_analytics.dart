import 'package:flutter/material.dart';
import 'package:folks_app/screens/admins/mainpage.dart';
import 'package:folks_app/widgets/admins/custom_tab_bar.dart';
import 'package:folks_app/providers/restaurant_provider.dart';
import 'package:provider/provider.dart';

class PartnerAnalyticsScreen extends StatefulWidget {
  const PartnerAnalyticsScreen({super.key});

  @override
  _PartnerAnalyticsScreen createState() => _PartnerAnalyticsScreen();
}

class _PartnerAnalyticsScreen extends State<PartnerAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<RestaurantProvider>(context, listen: false).fetchAllRestaurants();
    Provider.of<RestaurantProvider>(context, listen: false).fetchUnapprovedRestaurants();
  }

  @override
  Future<Widget> build(BuildContext context) async {
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
              change: '▲ 5',
              changeColor: Colors.green,
            ),
            // _buildAnalyticsCard(
            //   title: 'Total Users',
            //   value: '500', // Replace with your data
            //   change: '▼ 10',
            //   changeColor: Colors.red,
            // ),
            // Lowest Rating Partner
            _buildAnalyticsCard(
              title: 'Lowest Rating Partner',
              value: restaurantProvider.lowestRatingRestaurant?.name ?? 'N/A',
              additionalInfo: restaurantProvider.lowestRatingRestaurant != null
                  ? 'Rating: ${await restaurantProvider.lowestRatingRestaurant.getAverageRating()}'
                  : 'No rating available',
            ),

            // Highest Rating Partner
            _buildAnalyticsCard(
              title: 'Highest Rating Partner',
              value: restaurantProvider.highestRatingRestaurant?.name ?? 'N/A',
              additionalInfo: restaurantProvider.highestRatingRestaurant != null
                  ? 'Rating: ${await restaurantProvider.highestRatingRestaurant.getAverageRating()}'
                  : 'No rating available',
            ),
            _buildAnalyticsCard(
              title: 'Unapproved Partners',
              value: restaurantProvider.unapprovedRestaurantCount.toString(),
              change: '▲ 3%',
              changeColor: Colors.green,
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

import 'package:flutter/material.dart';
import 'package:folks_app/screens/admins/mainpage.dart';
import 'package:folks_app/widgets/admins/custom_tab_bar.dart';
import 'package:folks_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class CustomerAnalyticsScreen extends StatefulWidget {
  const CustomerAnalyticsScreen({super.key});

  @override
  _CustomerAnalyticsScreenState createState() => _CustomerAnalyticsScreenState();
}

class _CustomerAnalyticsScreenState extends State<CustomerAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).fetchAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
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
              child: CustomTabBar(index:2),
            ),
            const SizedBox(height: 16.0),

            // // Analytics Cards
            // _buildAnalyticsCard(
            //   title: 'Total Partners',
            //   value: '20', // Replace with your data
            //   change: '▲ 5',
            //   changeColor: Colors.green,
            // ),
            _buildAnalyticsCard(
              title: 'Total Users',
              value: userProvider.totalUserCount.toString(), // Replace with your data
              change: '▼ 10',
              changeColor: Colors.red,
            ),
            // _buildAnalyticsCard(
            //   title: 'Lowest Rating Partner',
            //   value: 'John\'s Café',
            //   additionalInfo: 'Rating: 2.0',
            // ),
            // _buildAnalyticsCard(
            //   title: 'Highest Rating Partner',
            //   value: 'Elite Dine',
            //   additionalInfo: 'Rating: 4.9',
            // ),
            // _buildAnalyticsCard(
            //   title: 'Average Order Value',
            //   value: 'MYR 25.40',
            //   change: '▲ 3%',
            //   changeColor: Colors.green,
            // ),
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

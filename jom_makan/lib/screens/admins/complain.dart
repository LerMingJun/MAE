import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/models/complain.dart';
import 'package:jom_makan/providers/complain_provider.dart';
import 'package:jom_makan/screens/admins/specific_complain.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_empty.dart';
import 'package:provider/provider.dart';

class ComplainsPage extends StatefulWidget {
  const ComplainsPage({super.key});

  @override
  _ComplainsPageState createState() => _ComplainsPageState();
}

class _ComplainsPageState extends State<ComplainsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load complains when the page initializes
    Provider.of<ComplainProvider>(context, listen: false).fetchComplains();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complains',
          style: GoogleFonts.lato(
            fontSize: 24,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.black,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Colors.green, width: 2.0),
              ),
              tabs: const [
                Tab(text: 'Resolved'),
                Tab(text: 'Unresolved'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildComplainTab(context, isResolved: true),
                _buildComplainTab(context, isResolved: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Generalized method for both resolved and unresolved tabs
  Widget _buildComplainTab(BuildContext context, {required bool isResolved}) {
    return Consumer<ComplainProvider>(
      builder: (context, provider, child) {
        final complains = isResolved
            ? provider.resolvedComplains
            : provider.unresolvedComplains;

        if (complains.isEmpty) {
          return const Center(
            child: EmptyWidget(
              text: "No Complains Found.\nPlease try again.",
              image:
                  'assets/projectEmpty.png', // Adjust the image path as needed
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: complains.length,
          itemBuilder: (context, index) {
            final complain = complains[index];
            return _buildComplainCard(complain);
          },
        );
      },
    );
  }

  // Helper method to create a complain card with consistent UI

  Widget _buildComplainCard(Complain complain) {
    return GestureDetector(
      /// The card is tappable and navigates to the complain detail screen when tapped.
      /// It displays the complain name, type, and ID.
      ///
      /// The card has a rounded border and elevation for a raised effect. Padding is
      /// applied to ensure content is not flush against the edges of the card.
      ///
      /// - Parameter complain: The complain object containing details to be displayed.
      onTap: () => navigateToComplainDetailScreen(context, complain),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                complain.name ?? 'No Name',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Type: ${complain.userType}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4.0),
              Text(
                'ID: ${complain.id}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void navigateToComplainDetailScreen(BuildContext context, Complain complain) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComplainDetailsScreen(
          complain: complain,
        ),
      ),
    );
  }
}

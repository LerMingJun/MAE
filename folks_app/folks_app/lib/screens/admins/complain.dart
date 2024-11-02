import 'package:flutter/material.dart';
import 'package:folks_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  _ComplaintsPageState createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load complaints when the page initializes
    Provider.of<UserProvider>(context, listen: false).loadClassifiedComplaints();
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
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Complaints',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
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
                _buildResolvedTab(context),
                _buildUnresolvedTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget to display resolved complaints
  Widget _buildResolvedTab(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        if (provider.resolvedComplaints.isEmpty) {
          return const Center(
            child: Text('No resolved complaints'),
          );
        }
        return ListView.builder(
          itemCount: provider.resolvedComplaints.length,
          itemBuilder: (context, index) {
            final complaint = provider.resolvedComplaints[index];
            return ListTile(
              title: Text(complaint['title'] ?? 'No Title'),
            );
          },
        );
      },
    );
  }

  // Widget to display unresolved complaints
  Widget _buildUnresolvedTab(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        if (provider.unresolvedComplaints.isEmpty) {
          return const Center(
            child: Text('No unresolved complaints'),
          );
        }
        return ListView.builder(
          itemCount: provider.unresolvedComplaints.length,
          itemBuilder: (context, index) {
            final complaint = provider.unresolvedComplaints[index];
            return ListTile(
              title: Text(complaint['title'] ?? 'No Title'),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:jom_makan/models/complain.dart';
import 'package:jom_makan/providers/complain_provider.dart';
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
              'complains',
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

  // Widget to display resolved complains
  Widget _buildResolvedTab(BuildContext context) {
    return Consumer<ComplainProvider>(
      builder: (context, provider, child) {
        if (provider.resolvedComplains.isEmpty) {
          return const Center(
            child: Text('No resolved complains'),
          );
        }
        return ListView.builder(
          itemCount: provider.resolvedComplains.length,
          itemBuilder: (context, index) {
            final complain = provider.resolvedComplains[index];
            return _buildRoundedBox(
              child: ListTile(
                title: Text(complain.description ?? '' ),
                subtitle: Text(
                  'Type: ${complain.userType}\nID: ${complain.id}',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget to display unresolved complains
  Widget _buildUnresolvedTab(BuildContext context) {
    return Consumer<ComplainProvider>(
      builder: (context, provider, child) {
        if (provider.unresolvedComplains.isEmpty) {
          return const Center(
            child: Text('No unresolved complains'),
          );
        }
        return ListView.builder(
          itemCount: provider.unresolvedComplains.length,
          itemBuilder: (context, index) {
            final complain = provider.unresolvedComplains[index];
            return _buildRoundedBox(
              child: ListTile(
                title: Text(complain.description ?? ''),
                subtitle: Text(
                  'Type: ${complain.userType}\nID: ${complain.id}',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to create a rounded box
  Widget _buildRoundedBox({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4.0,
            spreadRadius: 2.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

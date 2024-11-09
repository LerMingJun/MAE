import 'package:flutter/material.dart';
import 'package:jom_makan/models/complain.dart';
import 'package:provider/provider.dart';
import 'package:jom_makan/providers/complain_provider.dart'; // Import complain provider

class ComplaintPage extends StatefulWidget {
  final String userID; // Pass userID as a parameter
  final String userType; // Pass userType as a parameter

  const ComplaintPage({Key? key, required this.userID, required this.userType}) : super(key: key);

  @override
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final _complainController = TextEditingController();
  String selectedStatus = 'All'; // Added status filter (All, Pending, Resolved)
  bool isComplainMode = false; // To track if we are in complaint creation mode

  @override
  void initState() {
    super.initState();
    // Fetch the complaints when the page loads based on userID and userType
    Future.microtask(() =>
        Provider.of<ComplainProvider>(context, listen: false).fetchComplainsBasedonUserID(
          widget.userID, widget.userType)); // Using the passed userID and userType
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complaints"),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: SingleChildScrollView( // Wrap the entire Column with a SingleChildScrollView
        child: Column(
          children: [
            // Filter options for Pending or Resolved status
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,  // Light background color for the container
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2), // Shadow position
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Filter by Status',
                      labelStyle: TextStyle(color: Colors.deepPurple),
                      border: InputBorder.none,  // Removing default border
                    ),
                    style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                    items: [
                      DropdownMenuItem<String>(value: 'All', child: Row(children: [Icon(Icons.all_inbox, color: Colors.deepPurple), const SizedBox(width: 10), Text('All')])),
                      DropdownMenuItem<String>(value: 'Pending', child: Row(children: [Icon(Icons.pending, color: Colors.orange), const SizedBox(width: 10), Text('Pending')])),
                      DropdownMenuItem<String>(value: 'Resolved', child: Row(children: [Icon(Icons.check_circle, color: Colors.green), const SizedBox(width: 10), Text('Resolved')])),
                    ],
                    onChanged: (newStatus) {
                      setState(() {
                        selectedStatus = newStatus!;
                      });
                    },
                  ),
                ),
              ),
            ),

            // Display previously submitted complaints
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<ComplainProvider>(
                builder: (context, complainProvider, _) {
                  List<Complain> complaintsToDisplay = [];
                  if (selectedStatus == 'All') {
                    complaintsToDisplay = complainProvider.unresolvedComplains + complainProvider.resolvedComplains;
                  } else if (selectedStatus == 'Pending') {
                    complaintsToDisplay = complainProvider.unresolvedComplains;
                  } else if (selectedStatus == 'Resolved') {
                    complaintsToDisplay = complainProvider.resolvedComplains;
                  }

                  if (complaintsToDisplay.isEmpty) {
                    return const Center(child: Text("No complaints available."));
                  }

                  return ListView.builder(
                    shrinkWrap: true, // Set this to true to make ListView take only the required space
                    physics: NeverScrollableScrollPhysics(), // Disable scroll within this ListView
                    itemCount: complaintsToDisplay.length,
                    itemBuilder: (context, index) {
                      final complain = complaintsToDisplay[index];
                      return Card(
                        elevation: 8,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        color: complain.feedback.isEmpty ? Colors.amber[100] : Colors.green[100],
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(complain.description, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                complain.feedback.isEmpty ? 'Status: Pending' : 'Status: Resolved',
                                style: TextStyle(fontWeight: FontWeight.bold, color: complain.feedback.isEmpty ? Colors.orange : Colors.green),
                              ),
                              if (complain.feedback.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text('Feedback: ${complain.feedback}', style: TextStyle(color: Colors.blueAccent, fontStyle: FontStyle.italic)),
                                ),
                              if (complain.feedback.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text('No feedback available', style: TextStyle(color: Colors.grey)),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const Divider(),

            // Complaint submission form or button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isComplainMode)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isComplainMode = true; // Show the complaint text field
                        });
                      },
                      icon: const Icon(Icons.edit, color: Colors.black),
                      label: const Text('Submit a Complaint', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple, 
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  if (isComplainMode)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Describe your complaint",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _complainController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Enter your complaint description',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your complaint.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _submitComplaint,
                              icon: const Icon(Icons.send, color: Colors.black),
                              label: const Text('Submit Complaint', style: TextStyle(color: Colors.black)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  isComplainMode = false; // Cancel and close the form
                                  _complainController.clear(); // Clear text field
                                });
                              },
                              icon: const Icon(Icons.cancel, color: Colors.black),
                              label: const Text('Cancel', style: TextStyle(color: Colors.black)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent, 
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitComplaint() {
    if (_formKey.currentState?.validate() ?? false) {
      final complaintDescription = _complainController.text;

      final complainProvider = Provider.of<ComplainProvider>(context, listen: false);

      // Create a complain instance using the userID and userType passed to the page
      final complain = Complain(
        id: DateTime.now().toString(),  // Generate a unique ID (e.g., using timestamp)
        description: complaintDescription,
        feedback: '',  // Initially empty feedback
        userType: widget.userType,  // Use the passed userType
        userID: widget.userID,  // Use the passed userID
      );

      // Call the complain provider to handle the complaint submission
      complainProvider.submitComplain(complain, widget.userType);

      // Clear the text field after submission
      _complainController.clear();

      // Fetch the updated list of complaints
      Future.microtask(() {
        complainProvider.fetchComplainsBasedonUserID(widget.userID, widget.userType);
      });

      setState(() {
        isComplainMode = false; // Close the complaint input form
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint submitted successfully!')),

      );
    }
  }

}

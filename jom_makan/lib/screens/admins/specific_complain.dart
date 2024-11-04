// import 'package:flutter/material.dart';
// import 'package:jom_makan/screens/admins/mainpage.dart';
// import 'package:jom_makan/widgets/admins/custom_pull_up_widget.dart';

// class UserDetailsPage extends StatelessWidget {
//   const UserDetailsPage({super.key});

//   void _handleSend(String message) {
//     // Define the action when sending the message
//     print('Message sent: $message');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//          leading: BackButton(
//           onPressed: () {
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(builder: (context) => const MainPage()),
//             );
//           },
//         ),
//         title: const Text("User Details"),

//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // First Row: From and Joined Since
//                     const Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'From: New York',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                         Text(
//                           'Joined Since: January 2022',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),

//                     // Second Row: Rating
//                     Row(
//                       children: [
//                         const Text(
//                           'Rating:',
//                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(width: 8),
//                         Row(
//                           children: List.generate(5, (index) {
//                             return const Icon(
//                               Icons.star,
//                               color: Colors.amber,
//                               size: 20,
//                             );
//                           }),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),

//                     // Third Row: Title
//                     const Text(
//                       'Title: A wonderful experience!',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 16),

//                     // Content Section
//                     const Text(
//                       'Content: This user shared a wonderful experience with our platform, appreciating the ease of use and the support team’s quick response. They mentioned it has become their go-to app for all restaurant needs and were particularly pleased with the reservation system.',
//                       style: TextStyle(fontSize: 16),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           // Adding Pull-Up Widget
//           PullUpWidget(
//             title: 'Send Message',
//             content: 'Enter your message below.',
//             onSend: _handleSend,
//           ),
//         ],
//       ),
//     );
//   }
// }

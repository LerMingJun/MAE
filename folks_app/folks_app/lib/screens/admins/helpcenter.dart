import 'package:flutter/material.dart';
import 'package:folks_app/models/help_item.dart';

class HelpCenterScreen extends StatefulWidget {
  @override
  _HelpCenterScreenState createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
   List<HelpItem> helpItems = [
    HelpItem(title: 'How to update item photos', subtitle: 'Menu and Catalogue'),
    HelpItem(title: 'Request to update outlet address', subtitle: 'Account'),
    HelpItem(title: 'How to cancel a GrabFood or GrabMart order', subtitle: 'Orders and Transactions'),
    HelpItem(title: 'How to update menu item/price', subtitle: 'Menu and Catalogue'),
    HelpItem(title: 'Request to update banking details', subtitle: 'Account'),
    HelpItem(title: 'Report other issues as a merchant', subtitle: 'Orders and Transactions'),
    HelpItem(title: 'How to create and manage items/categories for my GrabFood menu', subtitle: 'Menu and Catalogue'),
    HelpItem(title: 'I have an issue regarding a delivery partner', subtitle: 'Feedback to Grab'),
    HelpItem(title: 'I have an issue regarding a delivery partner', subtitle: 'Feedback to Grab'),
    HelpItem(title: 'I have an issue regarding a delivery partner', subtitle: 'Feedback to Grab'),
  ];
  
  // Method to add a new item
  void addItem(HelpItem item) {
    setState(() {
      helpItems.add(item);
    });
  }

  // Method to remove an item
  void removeItem(int index) {
    setState(() {
      helpItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background green container
          Container(
            height: 150, // Adjust this height to control the overlay effect
            color: Colors.green,
          ),
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                title: const Text('Help Centre'),
                backgroundColor: Colors.transparent,
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                    ),
                    itemCount: helpItems.length,
                    itemBuilder: (context, index) {
                      final item = helpItems[index];
                      return GestureDetector(
                        onTap: () {
                          // Handle item tap here
                          print('${item.title} tapped');
                        },
                        child: SizedBox(
                          height: 120, // Fixed height for each box
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/hand.jpg',
                                    width: 18,
                                    height: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 4,
                                    ),
                                  ),
                                ],
                                  ),
                                  const Spacer(),
                                 
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Help Centre'),
//         backgroundColor: Colors.green,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 16.0),
//               child: Text(
//                 'Useful for your business',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//             Expanded(
//               child: GridView.builder(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   mainAxisSpacing: 8.0,
//                   crossAxisSpacing: 8.0,
//                 ),
//                 itemCount: helpItems.length,
//                 itemBuilder: (context, index) {
//                   final item = helpItems[index];
//                   return GestureDetector(
//                     onTap: () {
//                       // Handle item tap here
//                       print('${item.title} tapped');
//                     },
//                     child: SizedBox(
//                       height: 120, // Fixed height for each box
//                       child: Card(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         elevation: 2,
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Image.asset(
//                                     'assets/hand.jpg',
//                                     width: 18,
//                                     height: 18,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                     child: Text(
//                                       item.title,
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                       overflow: TextOverflow.ellipsis,
//                                       maxLines: 2,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const Spacer(),
//                               Text(
//                                 item.subtitle,
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


class HelpItem {
  final String title;
  final String subtitle;

  HelpItem({required this.title, required this.subtitle});    

}

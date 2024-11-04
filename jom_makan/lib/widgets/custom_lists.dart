import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_loading.dart';

class CustomList extends StatelessWidget {
  final String imageUrl;
  final String? eventID;
  final String? speechID;
  final String title;
  final String date;
  final String image;
  final void Function(BuildContext) onPressed;

  const CustomList({
    required this.imageUrl,
    this.eventID,
    this.speechID,
    required this.title,
    required this.date,
    required this.image,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Slidable(
            key: Key(title),
            endActionPane: ActionPane(
              extentRatio: 0.4,
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: onPressed,

                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                eventID != null
                    ? Navigator.pushNamed(
                        context,
                        '/eventDetail',
                        arguments: eventID,
                      )
                    : Navigator.pushNamed(
                        context,
                        '/speechDetail',
                        arguments: speechID,
                      );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    image,
                    width: 100,
                    height: 70,
                    fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return CustomImageLoading(width: 100);
                          }
                        },
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          date,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.placeholder,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(
          color: Colors.grey,
          thickness: 1,
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:jom_makan/models/participation.dart';
// import 'package:jom_makan/providers/participation_provider.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:jom_makan/theming/custom_themes.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:table_calendar/table_calendar.dart';

// class Schedule extends StatefulWidget {
//   const Schedule({super.key});

//   @override
//   State<Schedule> createState() => _ScheduleState();
// }

// class _ScheduleState extends State<Schedule> {
//   DateTime? _selectedDay;
//   DateTime? _rangeStart;
//   DateTime? _rangeEnd;
//   DateTime _focusedDay = DateTime.now();
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
//   late final ValueNotifier<List<Participation>> _selectedEvents;

//   @override
//   void initState() {
//     super.initState();
//     final participationProvider = Provider.of<ParticipationProvider>(context, listen: false);

//     _selectedDay = _focusedDay;
//     _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//         participationProvider.fetchAllActivitiesByUserID();
//     });
//   }

//   @override
//   void dispose() {
//     _selectedEvents.dispose();
//     super.dispose();
//   }

//   List<Participation> _getEventsForDay(DateTime day) {
//     final participationProvider = Provider.of<ParticipationProvider>(context, listen: false);
//     return participationProvider.getEventsForDay(day);
//   }

//   void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
//     if (!isSameDay(_selectedDay, selectedDay)) {
//       setState(() {
//         _selectedDay = selectedDay;
//         _focusedDay = focusedDay;
//         _rangeStart = null;
//         _rangeEnd = null;
//         _rangeSelectionMode = RangeSelectionMode.toggledOff;
//       });

//       _selectedEvents.value = _getEventsForDay(selectedDay);
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     final participationProvider = Provider.of<ParticipationProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text.rich(
//           TextSpan(
//             children: [
//               TextSpan(
//                 text: 'My ',
//                 style: GoogleFonts.lato(fontSize: 24),
//               ),
//               TextSpan(
//                 text: 'Schedules',
//                 style: GoogleFonts.lato(
//                     fontSize: 24,
//                     color: AppColors.primary,
//                     fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ),
//       ),
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//           child: Column(
//             children: [
//               TableCalendar(
//                 locale: 'en_UK',
//                 focusedDay: _focusedDay,
//                 firstDay: DateTime.utc(2010, 1, 12),
//                 lastDay: DateTime.utc(2050, 12, 31),
//                 selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//                 rangeStartDay: _rangeStart,
//                 rangeEndDay: _rangeEnd,
//                 calendarFormat: _calendarFormat,
//                 rangeSelectionMode: _rangeSelectionMode,
//                 eventLoader: (day) => participationProvider.getEventsForDay(day),
//                 startingDayOfWeek: StartingDayOfWeek.monday,
//                 calendarStyle: const CalendarStyle(
//                   outsideDaysVisible: false,
//                 ),
//                 onDaySelected: _onDaySelected,
//                 //onRangeSelected: _onRangeSelected,
//                 onFormatChanged: (format) {
//                   if (_calendarFormat != format) {
//                     setState(() {
//                       _calendarFormat = format;
//                     });
//                   }
//                 },
//                 onPageChanged: (focusedDay) {
//                   _focusedDay = focusedDay;
//                 },
//               ),
//               const SizedBox(height: 8.0),
//               Expanded(
//                 child: ValueListenableBuilder<List<Participation>>(
//                   valueListenable: _selectedEvents,
//                   builder: (context, value, _) {
//                     return ListView.builder(
//                       itemCount: value.length,
//                       itemBuilder: (context, index) {
//                         return Container(
//                             margin: const EdgeInsets.symmetric(
//                               horizontal: 5.0,
//                               vertical: 7.0,
//                             ),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12.0),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.grey.withOpacity(0.2),
//                                     spreadRadius: 2,
//                                     blurRadius: 5,
//                                     offset: const Offset(
//                                         0, 3),
//                                   ),
//                                 ],
//                               ),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     width: 5,
//                                     height: 80,
//                                     decoration: BoxDecoration(
//                                       color: value[index].type == 'project'
//                                           ? Colors.blue
//                                           : Colors
//                                               .green, // Color based on event type
//                                       borderRadius: const BorderRadius.only(
//                                         topLeft: Radius.circular(12.0),
//                                         bottomLeft: Radius.circular(12.0),
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: ListTile(
//                                       onTap: () {
//                                         Navigator.pushNamed(
//                                           context,
//                                           value[index].type == 'project'
//                                               ? '/eventDetail'
//                                               : '/speechDetail',
//                                           arguments: value[index].activityID,
//                                         );
//                                       },
//                                       title: Text(
//                                         value[index].title,
//                                         style: GoogleFonts.merriweather(
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       subtitle: Text(
//                                         value[index].location,
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 11,
//                                           color: AppColors.placeholder,
//                                         ),
//                                       ),
//                                       trailing: Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Text(
//                                             DateFormat('HH').format(
//                                                 value[index].hostDate.toDate()),
//                                             style: GoogleFonts.poppins(
//                                               fontSize: 16,
//                                               color: AppColors.secondary,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           Text(
//                                             DateFormat('mm').format(
//                                                 value[index].hostDate.toDate()),
//                                             style: GoogleFonts.poppins(
//                                               fontSize: 16,
//                                               color: AppColors.secondary,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       leading: Icon(
//                                         value[index].type == 'project'
//                                             ? Icons.diversity_3_outlined
//                                             : Icons.campaign_outlined,
//                                         size: 25,
//                                         color: value[index].type == 'project'
//                                             ? Colors.blue
//                                             : AppColors.primary,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ));
//                       },
//                     );
//                   },
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Row(
                    
//                     children: [
//                       const Icon(
//                         Icons.diversity_3_outlined,
//                         size: 20,
//                         color: Colors.blue,
//                       ),
//                       const SizedBox(width: 3),
//                       Text(
//                         'Project',
//                         style: GoogleFonts.poppins(
//                           fontSize: 15,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 1,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(width: 7),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.campaign,
//                         size: 20,
//                         color: AppColors.primary,
//                       ),
//                       const SizedBox(width: 3),
//                       Text(
//                         'Speech',
//                         style: GoogleFonts.poppins(
//                           fontSize: 15,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 1,
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

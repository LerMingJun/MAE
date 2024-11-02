import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:folks_app/providers/auth_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:folks_app/screens/admins/mainpage.dart';
import 'package:folks_app/providers/restaurant_provider.dart';
import 'package:folks_app/providers/user_provider.dart';
import 'package:folks_app/repositories/complain_repository.dart'; // Adjust the import according to your structure

Future<void> main() async {
  // Ensure widget binding is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize date formatting
  await initializeDateFormatting();

  // Directly instantiate complainRepository and call fetchClassifiedComplaints
  ComplainRepository complainRepository = ComplainRepository();
  print('Fetching classified complaints...'); // Adjust as necessary
      await complainRepository.fetchUserComplaints();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider(null)),
      ],
      child: const MaterialApp(
        home: MainPage(),
      ),
    );
  }
}

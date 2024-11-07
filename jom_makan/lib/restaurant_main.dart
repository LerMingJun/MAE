import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jom_makan/providers/complain_provider.dart';
import 'package:jom_makan/providers/helpitem_provider.dart';
import 'package:jom_makan/providers/review_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:jom_makan/screens/restaurant/signup.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/providers/store_provider.dart';
import 'package:jom_makan/providers/auth_provider.dart'; // Import AuthProvider

Future<void> main() async {
  // Ensure widget binding is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize date formatting
  await initializeDateFormatting();

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
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => HelpItemProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => ComplainProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()), // Add AuthProvider
      ],
      child: MaterialApp(
        // home: RestaurantHome(),
        home: RestaurantSignUp(),
      ),
    );
  }
}

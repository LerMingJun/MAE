import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:folks_app/models/restaurant.dart';
import 'package:folks_app/providers/auth_provider.dart';
import 'package:folks_app/providers/bookmark_provider.dart';
import 'package:folks_app/providers/event_provider.dart';
import 'package:folks_app/providers/participation_provider.dart';
import 'package:folks_app/providers/post_provider.dart';
import 'package:folks_app/providers/speech_provider.dart';
import 'package:folks_app/providers/user_provider.dart';
import 'package:folks_app/providers/restaurant_provider.dart';
import 'package:folks_app/providers/review_provider.dart';
import 'package:folks_app/screens/onboarding/onboarding_screen.dart';
import 'package:folks_app/screens/user/addPost.dart';
import 'package:folks_app/screens/user/bookmark.dart';
import 'package:folks_app/screens/user/community.dart';
import 'package:folks_app/screens/user/editPost.dart';
import 'package:folks_app/screens/user/editProfile.dart';
import 'package:folks_app/screens/user/eventDetails.dart';
import 'package:folks_app/screens/user/events.dart';
import 'package:folks_app/screens/user/home.dart';
import 'package:folks_app/screens/user/home_screen.dart';
import 'package:folks_app/screens/user/login.dart';
import 'package:folks_app/screens/user/profile.dart';
import 'package:folks_app/screens/user/recording.dart';
import 'package:folks_app/screens/user/schedule.dart';
import 'package:folks_app/screens/user/signup.dart';
import 'package:folks_app/screens/user/speechDetails.dart';
import 'package:folks_app/screens/user/userPost.dart';
import 'package:folks_app/screens/user/addRestaurant.dart';
import 'package:folks_app/screens/user/restaurantList.dart';
import 'package:folks_app/screens/user/restaurantDetails.dart';
import 'package:folks_app/theming/custom_themes.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure widget binding is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize date formatting
  await initializeDateFormatting();
  
  // Run the main application widget
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Providing the necessary providers for the application
      providers: [
        ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider()..checkCurrentUser()),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(null),
          update: (context, authProvider, userProvider) {
            // Initialize UserProvider with current user data
            userProvider?.initialize(authProvider.user);
            return userProvider!;
          }),
        ChangeNotifierProvider(create: (context) => EventProvider()), 
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => SpeechProvider()),
        ChangeNotifierProvider(create: (_) => ParticipationProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: CustomTheme.lightTheme, // Light theme
            darkTheme: CustomTheme.darkTheme, // Dark theme
            // Set initial route based on user authentication state
            initialRoute: authProvider.userData != null ? '/homeScreen' : '/',
            routes: {
              '/': (context) => OnboardingScreens(), // Onboarding screen
              '/login': (context) => Login(), // Login screen
              '/signup': (context) => SignUp(), // Signup screen
              '/home': (context) => Home(), // Home screen
              '/events': (context) => Events(), // Events screen
              '/eventDetail': (context) => EventDetail(), // Event details screen
              '/addPost': (context) => AddPost(), // Add post screen
              '/community': (context) => Community(), // Community screen
              '/editProfile': (context) => EditProfile(), // Edit profile screen
              '/homeScreen': (context) => HomeScreen(), // Home screen for logged-in users
              '/profile': (context) => Profile(), // User profile screen
              '/bookmark': (context) => Bookmark(), // Bookmarked items screen
              '/addRestaurant': (context) => AddRestaurantScreen(), // Add Restaurant screen
              '/speechDetail': (context) => SpeechDetail(), // Speech details screen
              '/recording': (context) => Recording(), // Recording screen
              '/userPost': (context) => UserPost(), // User's posts screen
              '/editPost': (context) => EditPost(), // Edit post screen
              '/schedule': (context) => Schedule(), // User schedule screen
              '/restaurantList': (context) => RestaurantsPage(), // Restaurant list screen
            },
            onGenerateRoute: (RouteSettings settings) {
              if (settings.name == '/restaurantDetails') {
                final Restaurant restaurant = settings.arguments as Restaurant;
                return MaterialPageRoute(
                  builder: (context) => RestaurantDetailsScreen(restaurant: restaurant),
                );
              }
              return null; // If no matching route found
            },
          );
        },
      ),
    );
  }
}

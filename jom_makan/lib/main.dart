import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jom_makan/models/complain.dart';
import 'package:jom_makan/models/favorite.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/providers/auth_provider.dart';
import 'package:jom_makan/providers/complain_provider.dart';
import 'package:jom_makan/providers/favorite_provider.dart';
import 'package:jom_makan/providers/helpitem_provider.dart';
import 'package:jom_makan/providers/post_provider.dart';
import 'package:jom_makan/providers/reply_provider.dart';
import 'package:jom_makan/providers/store_provider.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/providers/review_provider.dart';
import 'package:jom_makan/providers/booking_provider.dart';
import 'package:jom_makan/screens/admins/mainpage.dart';
import 'package:jom_makan/screens/onboarding/onboarding_screen.dart';
import 'package:jom_makan/screens/restaurant/restaurant_home.dart';
import 'package:jom_makan/screens/restaurant/signup.dart';
import 'package:jom_makan/screens/user/addPost.dart';
import 'package:jom_makan/screens/user/community.dart';
import 'package:jom_makan/screens/user/editPost.dart';
import 'package:jom_makan/screens/user/editProfile.dart';
import 'package:jom_makan/screens/user/home.dart';
import 'package:jom_makan/screens/user/home_screen.dart';
import 'package:jom_makan/screens/user/login.dart';
import 'package:jom_makan/screens/user/profile.dart';
import 'package:jom_makan/screens/user/schedule.dart';
import 'package:jom_makan/screens/user/signup.dart';
import 'package:jom_makan/screens/user/userPost.dart';
import 'package:jom_makan/screens/user/addRestaurant.dart';
import 'package:jom_makan/screens/user/restaurantList.dart';
import 'package:jom_makan/screens/user/restaurantDetails.dart';
import 'package:jom_makan/screens/user/restaurantManage.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure widget binding is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  // await SomeInitialization();
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
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => HelpItemProvider()),
        ChangeNotifierProvider(create: (_) => ComplainProvider()),
        ChangeNotifierProvider(create: (_) => ReplyProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider(null)),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: CustomTheme.lightTheme, // Light theme
            darkTheme: CustomTheme.darkTheme, // Dark theme
            // Set initial route based on user authentication state
            initialRoute: authProvider.userData != null ? '/homeScreen' : '/login',
            routes: {
              '/login': (context) => Login(), // Login screen
              '/signup': (context) => const SignUp(), // Signup screen
              '/home': (context) => const Home(), // Home screen
              '/editProfile': (context) => const EditProfile(), // Edit profile screen
              '/homeScreen': (context) => const HomeScreen(), // Home screen for logged-in users
              '/profile': (context) => const Profile(), // User profile screen
              '/addRestaurant': (context) => const AddRestaurantScreen(), // Add Restaurant screen
              '/userPost': (context) => const UserPost(), // User's posts screen
              '/editPost': (context) => const EditPost(), // Edit post screen
              '/restaurantList': (context) => const RestaurantsPage(), // Restaurant list screen
              '/restaurantManagement': (context) => const RestaurantManagementPage(), // Restaurant management screen
              '/adminHome': (context) => const MainPage(), // Admin home screen
              '/restaurantSignUp': (context) => const RestaurantSignUp(), // Restaurant sign-up screen
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

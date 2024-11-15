import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/screens/user/community.dart';
import 'package:jom_makan/screens/user/restaurantList.dart';
import 'package:jom_makan/screens/user/home.dart';
import 'package:jom_makan/screens/user/profile.dart';
import 'package:jom_makan/screens/user/restaurantManage.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  final PageController _pageController = PageController();
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.fetchUserData();
    final String? userId = userProvider.userData?.userID;
    _pages = [
      const Home(),
      const RestaurantsPage(),
      const RestaurantManagementPage(),
      Community(
        userId: userId,
        userRole: "user",
      ),
      const Profile(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _page = index;
          });
        },
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _page,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: AppColors.primary),
          Icon(Icons.restaurant, size: 30, color: AppColors.primary),
          Icon(Icons.event_note, size: 30, color: AppColors.primary),
          Icon(Icons.groups, size: 30, color: AppColors.primary),
          Icon(Icons.person, size: 30, color: AppColors.primary),
        ],
        //color: Color.fromARGB(150, 152, 251, 152),
        color: AppColors.tertiary,
        backgroundColor: AppColors.background,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}

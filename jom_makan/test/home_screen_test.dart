import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:jom_makan/screens/user/home_screen.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:jom_makan/screens/user/restaurantList.dart';

// Mock User
class MockUser extends Mock implements firebase_auth.User {}

void main() {
  testWidgets('Initial page should be Home', (WidgetTester tester) async {
    final mockUser = MockUser();
    when(() => mockUser.uid).thenReturn('SC2GGcV1BDbA7xexbzOylh0rp002');
    when(() => mockUser.email).thenReturn('mingjun@test.com');
    when(() => mockUser.displayName).thenReturn('Test User');

    final userProvider = UserProvider(mockUser);
    await tester.pumpWidget(
      ChangeNotifierProvider<UserProvider>.value(
        value: userProvider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Verify Home is loaded as the first page
    expect(find.byIcon(Icons.home), findsOneWidget);
  });

  // testWidgets('Navigation should switch to other pages',
  //     (WidgetTester tester) async {
  //   final mockUser = MockUser();
  //   when(() => mockUser.uid).thenReturn('SC2GGcV1BDbA7xexbzOylh0rp002');
  //   when(() => mockUser.email).thenReturn('mingjun@test.com');
  //   when(() => mockUser.displayName).thenReturn('Test User');

  //   final userProvider = UserProvider(mockUser);
  //   await tester.pumpWidget(
  //     ChangeNotifierProvider<UserProvider>.value(
  //       value: userProvider,
  //       child: const MaterialApp(home: HomeScreen()),
  //     ),
  //   );

  //   // Tap on the "Restaurants" icon
  //   await tester.tap(find.byIcon(Icons.restaurant));
  //   await tester.pumpAndSettle();
  //   expect(find.byType(RestaurantsPage), findsOneWidget);
  // });
}

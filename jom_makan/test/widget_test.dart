import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jom_makan/widgets/Restaurant/custom_loading.dart';
import 'package:jom_makan/widgets/custom_empty.dart';
import 'package:jom_makan/widgets/custom_drop_down.dart';
import 'package:jom_makan/widgets/admins/custom_tab_bar.dart'; 

void main() {
  testWidgets('Testing CustomLoading, EmptyWidget, CustomDropdown and CustomTabBar widgets',
      (WidgetTester tester) async {
    // Test CustomLoading widget
    print('Testing CustomLoading widget...');
    await tester.pumpWidget(MaterialApp(home: Scaffold()));

    // Show loading indicator
    CustomLoading.show(tester.element(find.byType(Scaffold)));
    await tester.pump(); // Trigger a frame
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    print('CustomLoading is displayed.');

    // Hide the loading indicator
    CustomLoading.hide(tester.element(find.byType(Scaffold)));
    await tester.pump(); // Trigger a frame
    expect(find.byType(CircularProgressIndicator), findsNothing);
    print('CustomLoading is hidden.');

    // Test EmptyWidget
    print('Testing EmptyWidget...');
    const text = 'No Post Available';
    const image = 'assets/no-post.png';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyWidget(
            text: text,
            image: image,
          ),
        ),
      ),
    );

    expect(find.text(text), findsOneWidget);
    print('EmptyWidget text is displayed: $text');

    expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == image,
        ),
        findsOneWidget);
    print('EmptyWidget image is displayed: $image');

    // Test CustomDropdown
    print('Testing CustomDropdown widget...');
    List<String> options = ['Chinese', 'Indian', 'Italian', 'Mexican'];
    List<String> selectedOptions = [];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) {
            return CustomDropdown(
              options: options,
              selectedOptions: selectedOptions,
              onChanged: (updatedOptions) {
                setState(() {
                  selectedOptions = updatedOptions;
                });
              },
            );
          },
        ),
      ),
    ));

    // Tap to open the dropdown
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    // Verify if the dropdown items appear
    for (String option in options) {
      expect(find.text(option), findsOneWidget);
    }
    print('CustomDropdown options are displayed.');

    // Select an option and verify the change
    await tester.tap(find.text('Chinese'));
    await tester.pumpAndSettle();
    expect(selectedOptions, contains('Chinese'));
    print('Selected options: $selectedOptions');

    // Tap to open the dropdown again and select another option
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Indian'));
    await tester.pumpAndSettle();
    expect(selectedOptions, containsAll(['Chinese', 'Indian']));
    print('Selected options after second selection: $selectedOptions');

    // Test CustomTabBar
    print('Testing CustomTabBar widget...');
    // Build the CustomTabBar widget with the initial index set to 0
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomTabBar(index: 0),
        ),
      ),
    );

    // Verify that the tab bar has the correct number of tabs
    expect(find.byType(Tab), findsNWidgets(3));

    // Verify that the first tab has the correct label
    expect(find.text('Overview'), findsOneWidget);

    // Verify that the TabBarView displays the correct content for the first tab
    expect(find.text('Overview Content'), findsOneWidget);

    // Tap on the second tab (Partner) and wait for the animation to complete
    await tester.tap(find.text('Partner'));
    await tester.pumpAndSettle();

    // Verify that the second tab's content is displayed
    expect(find.text('Sales Content'), findsOneWidget);
    print('Partner tab content is displayed.');
    
    // Tap on the third tab (Customer) and wait for the animation to complete
    await tester.tap(find.text('Customer'));
    await tester.pumpAndSettle();
    
    // Verify that the third tab's content is displayed
    expect(find.text('Customers Content'), findsOneWidget);
    print('Customer tab content is displayed.');
  });
}

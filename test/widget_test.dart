import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wallhaven_app/providers/wallpaper_provider.dart';
import 'package:wallhaven_app/views/home_view.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Note: In a real environment, we'd use mockito to mock the provider and service.
// This is a basic sanity check test for the widget structure.

void main() {
  testWidgets('HomeView should display the app title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => WallpaperProvider(),
        child: const MaterialApp(
          home: HomeView(),
        ),
      ),
    );

    // Verify that the title exists
    expect(find.text('WALLHAVEN'), findsOneWidget);
    
    // Verify that the filter button exists
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
  });
}

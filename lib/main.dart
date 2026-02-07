import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/wallpaper_provider.dart';
import 'views/home_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WallpaperProvider()),
      ],
      child: const WallhavenApp(),
    ),
  );
}

class WallhavenApp extends StatelessWidget {
  const WallhavenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallhaven App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const HomeView(),
    );
  }
}

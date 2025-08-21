import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/movies/presentation/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const baseBlue = Color(0xFF0E1A2A);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movies',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: baseBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF17253D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

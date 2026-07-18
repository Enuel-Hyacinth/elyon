import 'package:flutter/material.dart';
import '../core/theme/theme.dart';
import '../features/splash/presentation/splash_screen.dart';

class ELyonApp extends StatelessWidget {
  const ELyonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eLyon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
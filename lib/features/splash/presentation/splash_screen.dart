import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  double opacity = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        opacity = 1;
      });
    });

    Timer(const Duration(seconds: 3), () {
      // Navigation comes later
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(seconds: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [

              Icon(
                Icons.auto_awesome,
                color: Color(0xFFD4AF37),
                size: 90,
              ),

              SizedBox(height: 24),

              Text(
                "eLyon",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              SizedBox(height: 12),

              Text(
                "Your AI Business Companion",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class AnimationScreen extends StatelessWidget {
  const AnimationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Animation Studio"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.movie_creation_outlined,
                size: 90,
                color: Color(0xFF6C63FF),
              ),

              SizedBox(height: 24),

              Text(
                "Animation Studio",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 12),

              Text(
                "Welcome to eLyon Animation Studio.\n\nYour project has been created successfully and Orion is preparing your creative workspace.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
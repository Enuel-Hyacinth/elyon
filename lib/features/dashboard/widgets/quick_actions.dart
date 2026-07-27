import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback? onAnimation;
  final VoidCallback? onImage;
  final VoidCallback? onVoice;
  final VoidCallback? onDirector;

  const QuickActions({
    super.key,
    this.onAnimation,
    this.onImage,
    this.onVoice,
    this.onDirector,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 18),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.45,
          children: [
            _ActionCard(
              title: "Animation",
              icon: Icons.movie_creation_outlined,
              color: Colors.deepPurple,
              onTap: onAnimation,
            ),

            _ActionCard(
              title: "Image",
              icon: Icons.image_outlined,
              color: Colors.orange,
              onTap: onImage,
            ),

            _ActionCard(
              title: "Voice",
              icon: Icons.mic_none_rounded,
              color: Colors.teal,
              onTap: onVoice,
            ),

            _ActionCard(
              title: "AI Director",
              icon: Icons.auto_awesome,
              color: Colors.indigo,
              onTap: onDirector,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.10),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),

              const Spacer(),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Open",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
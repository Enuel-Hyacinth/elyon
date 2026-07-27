import 'package:flutter/material.dart';

class QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ActionChip(
        elevation: 2,
        backgroundColor: const Color(0xFF1F1F1F),
        side: BorderSide(
          color: Colors.grey.shade800,
        ),
        avatar: Icon(
          icon,
          color: const Color(0xFF6C63FF),
          size: 20,
        ),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        onPressed: onTap,
      ),
    );
  }
}
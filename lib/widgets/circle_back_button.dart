import 'package:flutter/material.dart';

/// Semi-transparent circular back button used in every screen header.
class CircleBackButton extends StatelessWidget {
  const CircleBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

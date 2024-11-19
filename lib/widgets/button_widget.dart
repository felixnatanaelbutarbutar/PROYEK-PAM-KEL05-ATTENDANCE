import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  CustomButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50), // Full-width button
        // primary: Colors.green,
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}

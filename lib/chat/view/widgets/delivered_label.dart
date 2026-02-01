import 'package:flutter/material.dart';

class DeliveredLabel extends StatelessWidget {
  const DeliveredLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(vertical: 8, horizontal: 16),
      child: const Text('Delivered'),
    );
  }
}

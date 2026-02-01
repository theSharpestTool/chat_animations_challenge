import 'package:flutter/material.dart';

class DeliveredLabel extends StatelessWidget {
  const DeliveredLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .only(top: 8, right: 16, left: 16),
      child: const Text('Delivered'),
    );
  }
}

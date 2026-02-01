import 'package:flutter/material.dart';

/// {@template delivered_label}
/// Simple status label shown between chat bubbles indicating
/// which messages have been delivered.
/// {@endtemplate}
class DeliveredLabel extends StatelessWidget {
  /// {@macro delivered_label}
  const DeliveredLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .only(top: 8, right: 16, left: 16),
      child: const Text('Delivered'),
    );
  }
}

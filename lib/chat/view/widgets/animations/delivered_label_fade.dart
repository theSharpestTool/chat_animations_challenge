import 'package:advanced_chat_animations/chat/view/widgets/delivered_label.dart';
import 'package:flutter/material.dart';

/// {@template delivered_label_fade}
/// Animation that fades out the "Delivered" label.
///
/// Works in tandem with [DeliveredLabelScale], that also has [slideAnimation]:
/// [DeliveredLabelFade] height is reduced from 1 to 0 with a fade out, while
/// [DeliveredLabelScale] height is increased from 0 to 1 with a scale up, that
/// imitates the "Delivered" label sliding up.
/// {@endtemplate}
class DeliveredLabelFade extends StatelessWidget {
  /// {@macro delivered_label_fade}
  const DeliveredLabelFade({
    super.key,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  final Animation<double> fadeAnimation;
  final Animation<double> slideAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // Rebuild when any of these animations tick
      animation: Listenable.merge([fadeAnimation, slideAnimation]),
      child: const DeliveredLabel(),
      builder: (context, child) {
        return Align(
          heightFactor: 1 - slideAnimation.value,
          alignment: Alignment.topRight,
          child: Opacity(opacity: 1 - fadeAnimation.value, child: child),
        );
      },
    );
  }
}

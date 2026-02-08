import 'package:advanced_chat_animations/chat/view/widgets/delivered_label.dart';
import 'package:flutter/material.dart';

/// {@template delivered_label_scale}
/// Animation that scales up the "Delivered" label.
///
/// Works in tandem with [DeliveredLabelFade], that also has [slideAnimation]:
/// [DeliveredLabelFade] height is reduced from 1 to 0 with a fade out, while
/// [DeliveredLabelScale] height is increased from 0 to 1 with a scale up, that
/// imitates the "Delivered" label sliding up.
/// {@endtemplate}
class DeliveredLabelScale extends StatelessWidget {
  /// {@macro delivered_label_scale}
  const DeliveredLabelScale({
    super.key,
    required this.scaleAnimation,
    required this.slideAnimation,
  });

  final Animation<double> scaleAnimation;
  final Animation<double> slideAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // Rebuild when any of these animations tick
      animation: Listenable.merge([scaleAnimation, slideAnimation]),
      child: const DeliveredLabel(),
      builder: (context, child) {
        return Align(
          heightFactor: slideAnimation.value,
          alignment: Alignment.topRight,
          child: Transform.scale(
            scale: scaleAnimation.value,
            alignment: Alignment.topCenter,
            child: child,
          ),
        );
      },
    );
  }
}

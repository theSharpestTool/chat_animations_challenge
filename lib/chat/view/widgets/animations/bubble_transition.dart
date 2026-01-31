import 'package:advanced_chat_animations/chat/view/widgets/bubble.dart';
import 'package:flutter/material.dart';

class BubbleTransition extends StatelessWidget {
  const BubbleTransition({
    super.key,
    required this.animation,
    required this.startRect,
    required this.endRect,
    required this.text,
  });

  final Animation<double> animation;
  final Rect startRect;
  final Rect endRect;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final textTheme = theme.textTheme;

        final rect = RectTween(
          begin: startRect,
          end: endRect,
        ).evaluate(animation);
        final color = ColorTween(
          begin: colorScheme.surface,
          end: colorScheme.primary,
        ).evaluate(animation);
        final padding = EdgeInsetsGeometryTween(
          begin: .symmetric(horizontal: 16, vertical: 14),
          end: .symmetric(horizontal: 16, vertical: 10),
        ).evaluate(animation);
        final borderRadius = BorderRadiusTween(
          begin: .circular(24),
          end: .circular(18),
        ).evaluate(animation);
        final messageTextStyle = TextStyleTween(
          begin: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          end: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary),
        ).evaluate(animation);
        final timestampTextStyle = TextStyleTween(
          begin: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface,
            fontSize: 0,
          ),
          end: textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary),
        ).evaluate(animation);
        final verticalSpacing = Tween<double>(
          begin: 0,
          end: 4,
        ).evaluate(animation);

        return Positioned.fromRect(
          rect: rect!,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Bubble(
              text: text,
              timestamp: DateTime.now(),
              color: color,
              padding: padding,
              borderRadius: borderRadius,
              messageTextStyle: messageTextStyle,
              timestampTextStyle: timestampTextStyle,
              verticalSpacing: verticalSpacing,
            ),
          ),
        );
      },
    );
  }
}

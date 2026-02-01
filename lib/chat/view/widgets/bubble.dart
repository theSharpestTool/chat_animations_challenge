import 'package:boxy/flex.dart';
import 'package:flutter/material.dart';

/// {@template bubble}
/// Displays a chat bubble with message text and a formatted timestamp.
///
/// Allows styling overrides for color, padding, corner radius, and text styles.
/// {@endtemplate}
class Bubble extends StatelessWidget {
  /// {@macro bubble}
  const Bubble({
    required this.text,
    required this.timestamp,
    this.color,
    this.padding,
    this.borderRadius,
    this.messageTextStyle,
    this.timestampTextStyle,
    this.verticalSpacing,
    super.key,
  });

  final String text;
  final DateTime timestamp;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final TextStyle? messageTextStyle;
  final TextStyle? timestampTextStyle;
  final double? verticalSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: padding ?? .symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color ?? colorScheme.primary,
        borderRadius: borderRadius ?? .circular(18),
      ),
      // BoxyColumn lets the timestamp align to the end while keeping the text
      // aligned to the start.
      child: BoxyColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style:
                messageTextStyle ??
                textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary),
          ),
          SizedBox(height: verticalSpacing ?? 4),
          BoxyFlexible.align(
            crossAxisAlignment: CrossAxisAlignment.end,
            child: Text(
              _formatTimestamp(timestamp),
              style:
                  timestampTextStyle ??
                  textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

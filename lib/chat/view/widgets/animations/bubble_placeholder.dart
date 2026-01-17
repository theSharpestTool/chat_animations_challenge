import 'package:advanced_chat_animations/chat/view/widgets/bubble.dart';
import 'package:flutter/material.dart';

class BubblePlaceholder extends StatelessWidget {
  const BubblePlaceholder({
    super.key,
    required this.animation,
    required this.bubblePlaceholderKey,
    required this.text,
  });

  final Animation<double> animation;
  final Key bubblePlaceholderKey;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: Visibility.maintain(
        visible: false,
        child: Padding(
          padding: .only(top: 8),
          child: Bubble(
            key: bubblePlaceholderKey,
            text: text,
            timestamp: DateTime.now(),
          ),
        ),
      ),
      builder: (context, child) {
        return Align(
          heightFactor: animation.value,
          alignment: Alignment.bottomRight,
          child: child,
        );
      },
    );
  }
}

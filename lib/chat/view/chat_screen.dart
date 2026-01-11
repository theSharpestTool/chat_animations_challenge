import 'package:advanced_chat_animations/chat/chat.dart';
import 'package:boxy/flex.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  var _sendingMessages = <ChatMessage>[];
  var _deliveredMessages = <ChatMessage>[];

  final _inputFieldKey = GlobalKey();
  final _animatingBubbleKey = GlobalKey();

  final _textController = TextEditingController();
  late final AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  late final _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.decelerate,
  );
  String _animatingMessageText = '';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    _textController.clear();

    setState(() {
      _animatingMessageText = text;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final startRect = _inputFieldKey.rect;
      final endRect = _animatingBubbleKey.rect;

      final overlayEntry = OverlayEntry(
        builder: (context) {
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final rectTween = RectTween(begin: startRect, end: endRect);
              final rect = rectTween.evaluate(_animation);

              return Positioned.fromRect(
                rect: rect!,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: ChatBubbleTransition(
                    animation: _animation,
                    message: _animatingMessageText,
                    timestamp: DateTime.now(),
                  ),
                ),
              );
            },
          );
        },
      );
      Overlay.of(context).insert(overlayEntry);

      await _animationController.forward();
      _animationController.reset();
      overlayEntry.remove();

      if (text.isNotEmpty) {
        final newMessage = ChatMessage(text: text, timestamp: DateTime.now());

        setState(() {
          _sendingMessages = [newMessage, ..._sendingMessages];
        });

        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          _sendingMessages.remove(newMessage);
          _deliveredMessages = [newMessage, ..._deliveredMessages];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const bubbleSpacing = 8.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat Screen')),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              reverse: true,
              slivers: [
                SliverToBoxAdapter(child: const SizedBox(height: 16)),
                SliverPadding(
                  padding: .symmetric(horizontal: 8.0),
                  sliver: SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: _animation,
                      child: Visibility.maintain(
                        visible: false,
                        child: Padding(
                          padding: .only(top: bubbleSpacing),
                          child: ChatBubble(
                            key: _animatingBubbleKey,
                            message: _animatingMessageText,
                            timestamp: DateTime.now(),
                          ),
                        ),
                      ),
                      builder: (context, child) {
                        return Align(
                          heightFactor: _animation.value,
                          alignment: Alignment.bottomRight,
                          child: child,
                        );
                      },
                    ),
                  ),
                ),
                if (_sendingMessages.isNotEmpty)
                  SliverPadding(
                    padding: .only(left: 8.0, right: 8.0, top: bubbleSpacing),
                    sliver: SliverList.separated(
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: bubbleSpacing),
                      itemCount: _sendingMessages.length,
                      itemBuilder: (context, index) {
                        final message = _sendingMessages[index];
                        return Align(
                          alignment: Alignment.centerRight,
                          child: ChatBubble(
                            message: message.text,
                            timestamp: message.timestamp,
                          ),
                        );
                      },
                    ),
                  ),
                if (_deliveredMessages.isNotEmpty)
                  SliverPadding(
                    padding: .only(right: 16.0, top: bubbleSpacing),
                    sliver: SliverToBoxAdapter(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text('Delivered'),
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: .symmetric(horizontal: 8.0),
                  sliver: SliverList.separated(
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: bubbleSpacing),
                    itemCount: _deliveredMessages.length,
                    itemBuilder: (context, index) {
                      final message = _deliveredMessages[index];
                      return Align(
                        alignment: Alignment.centerRight,
                        child: ChatBubble(
                          message: message.text,
                          timestamp: message.timestamp,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: .all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: _inputFieldKey,
                        controller: _textController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: .all(Radius.circular(24)),
                          ),
                          contentPadding: .symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubbleTransition extends StatelessWidget {
  const ChatBubbleTransition({
    required this.animation,
    required this.message,
    required this.timestamp,
    super.key,
  });

  final Animation<double> animation;
  final String message;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
    final verticalSpacing = Tween<double>(begin: 0, end: 4).evaluate(animation);

    return ChatBubble(
      message: message,
      timestamp: timestamp,
      color: color,
      padding: padding,
      borderRadius: borderRadius,
      messageTextStyle: messageTextStyle,
      timestampTextStyle: timestampTextStyle,
      verticalSpacing: verticalSpacing,
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    required this.message,
    required this.timestamp,
    this.color,
    this.padding,
    this.borderRadius,
    this.messageTextStyle,
    this.timestampTextStyle,
    this.verticalSpacing,
    super.key,
  });

  final String message;
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
      child: BoxyColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
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

extension on GlobalKey {
  Rect? get rect {
    final renderObject = currentContext?.findRenderObject();
    if (renderObject is! RenderBox) {
      return null;
    }

    final offset = renderObject.localToGlobal(Offset.zero);
    final size = renderObject.size;
    return offset & size;
  }
}

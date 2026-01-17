import 'package:advanced_chat_animations/chat/models/chat_message.dart';
import 'package:advanced_chat_animations/chat/view/widgets/animations/bubble_placeholder.dart';
import 'package:advanced_chat_animations/chat/view/widgets/animations/bubble_transition.dart';
import 'package:advanced_chat_animations/chat/view/widgets/bubble.dart';
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
  final _bubblePlaceholderKey = GlobalKey();

  final _textController = TextEditingController();

  late final _bubbleTransitionController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  late final _bubbleTransitionAnimation = CurvedAnimation(
    parent: _bubbleTransitionController,
    curve: Curves.decelerate,
  );
  String _bubbleTransitionText = '';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    _textController.clear();

    setState(() {
      _bubbleTransitionText = text;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final startRect = _inputFieldKey.rect;
      final endRect = _bubblePlaceholderKey.rect;

      final overlayEntry = OverlayEntry(
        builder: (context) {
          return BubbleTransition(
            animation: _bubbleTransitionAnimation,
            startRect: startRect,
            endRect: endRect,
            text: _bubbleTransitionText,
          );
        },
      );
      Overlay.of(context).insert(overlayEntry);

      await _bubbleTransitionController.forward();
      _bubbleTransitionController.reset();
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
                    child: BubblePlaceholder(
                      animation: _bubbleTransitionAnimation,
                      bubblePlaceholderKey: _bubblePlaceholderKey,
                      text: _bubbleTransitionText,
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
                          child: Bubble(
                            text: message.text,
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
                        child: Bubble(
                          text: message.text,
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

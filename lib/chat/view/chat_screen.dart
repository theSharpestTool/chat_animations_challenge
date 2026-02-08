import 'package:advanced_chat_animations/chat/models/chat_message.dart';
import 'package:advanced_chat_animations/chat/view/widgets/animations/bubble_placeholder.dart';
import 'package:advanced_chat_animations/chat/view/widgets/animations/bubble_transition.dart';
import 'package:advanced_chat_animations/chat/view/widgets/animations/delivered_label_fade.dart';
import 'package:advanced_chat_animations/chat/view/widgets/animations/delivered_label_scale.dart';
import 'package:advanced_chat_animations/chat/view/widgets/bubble.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  /// List of messages that are currently animating (sending). Displayed below the delivered label.
  var _animatingMessages = <ChatMessage>[];

  /// List of messages that have been delivered. Displayed above the delivered label.
  var _deliveredMessages = <ChatMessage>[];

  /// Key of input field to get its position as a starting point for bubble transition animation.
  final _inputFieldKey = GlobalKey();

  /// Key of bubble placeholder to get its position as an ending point for bubble transition animation.
  final _bubblePlaceholderKey = GlobalKey();

  final _textController = TextEditingController();

  /// Drives the overlay bubble flight from input to placeholder.
  late final _bubbleTransitionController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  late final _bubbleTransitionAnimation = CurvedAnimation(
    parent: _bubbleTransitionController,
    curve: Curves.decelerate,
  );

  /// Text snapshot used by the overlay bubble during the transition.
  String _bubbleTransitionText = '';

  /// Drives the list shift and delivered label reveal once sent.
  late final _bubbleSlideController = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  late final _bubbleSlideAnimation = CurvedAnimation(
    parent: _bubbleSlideController,
    curve: Curves.decelerate,
  );

  /// Fades the delivered label in during the first half of the slide.
  /// Has inteval from 0 to 0.6:
  /// - starts fading out when the slide animation starts
  /// - completes fade out when the slide animation is at 60%
  late final _deliveredLabelFadeAnimation = CurvedAnimation(
    parent: _bubbleSlideController,
    curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
  );

  /// Scales the delivered label up toward the end of the slide.
  /// Has inteval from 0.4 to 1:
  /// - starts scaling up when the slide animation is at 40%
  /// - completes scaling up along with the slide animation at 100%
  late final _deliveredLabelScaleAnimation = CurvedAnimation(
    parent: _bubbleSlideController,
    curve: const Interval(0.4, 1.0, curve: Curves.easeOutSine),
  );

  @override
  void dispose() {
    _textController.dispose();
    _bubbleTransitionController.dispose();
    _bubbleSlideController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    // Prevent sending a new message while an animation is in progress.
    if (_bubbleTransitionController.isAnimating ||
        _bubbleSlideController.isAnimating) {
      return;
    }

    final text = _textController.text.trim();
    if (text.isEmpty) {
      return;
    }
    _textController.clear();

    setState(() {
      _bubbleTransitionText = text;
    });

    // Use post frame callback to ensure input field (start position) and
    // bubble placeholder (end position) have been rendered before starting the animation.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final startRect = _inputFieldKey.rect;
      final endRect = _bubblePlaceholderKey.rect;
      if (startRect == null || endRect == null) {
        return;
      }

      // Insert the overlay entry with the flying bubble.
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

      // Start the bubble transition animation and wait for it to complete.
      // Once completed, remove the overlay entry.
      await _bubbleTransitionController.forward();
      _bubbleTransitionController.reset();
      overlayEntry.remove();

      // Add the new message to the animating list.
      final newMessage = ChatMessage(text: text, timestamp: DateTime.now());
      if (!mounted) return;
      setState(() {
        _animatingMessages = [newMessage, ..._animatingMessages];
      });

      // Simulate a network delay for sending the message before starting the slide animation.
      await Future.delayed(const Duration(seconds: 2));

      // Once delivered, start the slide animation to move the bubble up and reveal the delivered label.
      await _bubbleSlideController.forward();
      _bubbleSlideController.reset();

      // When animation completes, move the message from animating to delivered list.
      if (!mounted) return;
      setState(() {
        _animatingMessages.remove(newMessage);
        _deliveredMessages = [newMessage, ..._deliveredMessages];
      });
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
              reverse: true, // Start from the bottom, like typical chat apps
              slivers: [
                SliverToBoxAdapter(child: const SizedBox(height: 16)),

                // The bubble placeholder animates its height from 0 to full bubble size during the bubble transition.
                // This reserves the space for the incoming bubble and lifts all existing content up smoothly. 
                // _bubblePlaceholderKey is used to get the end position of the flying bubble.
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

                // First "Delivered" label (works in tandem with DeliveredLabelFade):
                // scales up from 0 to full size making _animatingMessages appear to slide up with it.
                SliverToBoxAdapter(
                  child: DeliveredLabelScale(
                    scaleAnimation: _deliveredLabelScaleAnimation,
                    slideAnimation: _bubbleSlideAnimation,
                  ),
                ),

                // List of messages that are currently animating (sending). 
                // These are the messages that have been sent but not yet delivered.
                if (_animatingMessages.isNotEmpty)
                  SliverPadding(
                    padding: .only(left: 8.0, right: 8.0, top: bubbleSpacing),
                    sliver: SliverList.separated(
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: bubbleSpacing),
                      itemCount: _animatingMessages.length,
                      itemBuilder: (context, index) {
                        final message = _animatingMessages[index];
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

                // Second "Delivered" label (works in tandem with DeliveredLabelScale):
                // fades out from full size and opacity to 0, making _deliveredMessages appear to slide up and take its place.
                if (_deliveredMessages.isNotEmpty)
                  SliverToBoxAdapter(
                    child: DeliveredLabelFade(
                      fadeAnimation: _deliveredLabelFadeAnimation,
                      slideAnimation: _bubbleSlideAnimation,
                    ),
                  ),

                // List of messages that have completed the sending animation and are now delivered.
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

          // Input field and send button.
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
                      // _inputFieldKey is used to get the start position of the flying bubble.
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
  /// Returns the global [Rect] of the widget associated with this key, or null if it cannot be determined.
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

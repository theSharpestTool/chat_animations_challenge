import 'package:advanced_chat_animations/chat/bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  late final AnimationController _animationController = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  );
  late final _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.decelerate,
  );
  String _animatingMessage = '';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final bloc = context.read<ChatBloc>();
    final text = _textController.text.trim();
    _textController.clear();

    setState(() {
      _animatingMessage = text;
    });
    await _animationController.forward();
    _animationController.reset();

    if (text.isNotEmpty) {
      bloc.add(ChatSendPressed(text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Screen')),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                const bubbleSpacing = 8.0;

                return CustomScrollView(
                  reverse: true,
                  slivers: [
                    SliverToBoxAdapter(
                      child: const SizedBox(height: bubbleSpacing),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      sliver: SliverToBoxAdapter(
                        child: SizeTransition(
                          sizeFactor: _animation,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: bubbleSpacing),
                            child: ChatBubble(
                              message: _animatingMessage,
                              timestamp: DateTime.now(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: const SizedBox(height: bubbleSpacing),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      sliver: SliverList.separated(
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: bubbleSpacing),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          return ChatBubble(
                            message: message.text,
                            timestamp: message.timestamp,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
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
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
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

class ChatBubble extends StatelessWidget {
  const ChatBubble({required this.message, required this.timestamp, super.key});

  final String message;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

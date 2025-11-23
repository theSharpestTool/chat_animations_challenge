part of 'chat_bloc.dart';

@immutable
final class ChatState {
  const ChatState({required this.messages});

  final List<ChatMessage> messages;
}

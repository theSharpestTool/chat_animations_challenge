part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {
  const ChatEvent();
}

class ChatSendPressed extends ChatEvent {
  final String messageText;

  const ChatSendPressed(this.messageText);
}

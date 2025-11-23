import 'dart:async';

import 'package:advanced_chat_animations/chat/models/chat_message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatState(messages: [])) {
    on<ChatSendPressed>(_onSendPressed);
  }

  Future<void> _onSendPressed(
    ChatSendPressed event,
    Emitter<ChatState> emit,
  ) async {
    final newMessage = ChatMessage(text: event.messageText, timestamp: DateTime.now());

    final updatedMessages = [...state.messages, newMessage];

    emit(ChatState(messages: updatedMessages));
  }
}

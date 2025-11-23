import 'package:advanced_chat_animations/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Advanced Animations App',
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => ChatBloc(),
        child: ChatScreen(),
      ),
    );
  }
}

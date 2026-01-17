import 'package:advanced_chat_animations/chat/view/chat_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Advanced Animations App',
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

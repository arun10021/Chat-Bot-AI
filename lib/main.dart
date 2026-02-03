import 'package:chat_bot_ai/provider/chat_provdier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'config/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          return MaterialApp(
            title: 'AI Chat Assistant',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: chatProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const ChatScreen(),
          );
        },
      ),
    );
  }
}
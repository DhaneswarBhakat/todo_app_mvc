import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/todo_controller.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import 'todo_list_screen.dart';
import 'splash_screen.dart';
import 'login_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TodoController()),
        ChangeNotifierProvider(create: (context) => ThemeService()),
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: Consumer2<ThemeService, AuthService>(
        builder: (context, themeService, authService, child) {
          return MaterialApp(
            title: 'Todo App MVC',
            themeMode: themeService.themeMode,
            theme: themeService.lightTheme,
            darkTheme: themeService.darkTheme,
            home: authService.isAuthenticated ? const TodoListScreen() : const LoginScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
} 
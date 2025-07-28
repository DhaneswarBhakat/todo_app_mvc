import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/todo_controller.dart';
import '../services/theme_service.dart';
import 'todo_list_screen.dart';
import 'splash_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TodoController()),
        ChangeNotifierProvider(create: (context) => ThemeService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Todo App MVC',
            themeMode: themeService.themeMode,
            theme: themeService.lightTheme,
            darkTheme: themeService.darkTheme,
            home: const TodoListScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
} 
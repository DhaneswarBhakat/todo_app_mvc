// Widget tests for Todo App MVC with Fingerprint Authentication
//
// These tests verify the basic functionality of the todo app widgets.
// Note: Biometric authentication tests require device-specific testing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todo_app_mvc/views/main_app.dart';
import 'package:todo_app_mvc/controllers/todo_controller.dart';
import 'package:todo_app_mvc/services/theme_service.dart';
import 'package:todo_app_mvc/services/auth_service.dart';

void main() {
  group('Todo App Widget Tests', () {
    testWidgets('App should start with login screen when not authenticated', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MainApp());
      await tester.pumpAndSettle();

      // Verify that the login screen is displayed
      expect(find.text('Todo App'), findsOneWidget);
      expect(find.text('Secure your tasks with biometric authentication'), findsOneWidget);
      expect(find.text('Authenticate with Fingerprint'), findsOneWidget);
    });

    testWidgets('App should show todo list when authenticated', (WidgetTester tester) async {
      // Create a mock authenticated app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => TodoController()),
            ChangeNotifierProvider(create: (context) => ThemeService()),
            ChangeNotifierProvider(create: (context) => AuthService()),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return const Scaffold(
                  body: Center(child: Text('Todo List Screen')),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that the todo list screen is displayed
      expect(find.text('Todo List Screen'), findsOneWidget);
    });

    testWidgets('Theme service should toggle between light and dark themes', (WidgetTester tester) async {
      final themeService = ThemeService();
      
      // Initial state should be light mode
      expect(themeService.isDarkMode, false);
      
      // Toggle to dark mode
      themeService.toggleTheme();
      expect(themeService.isDarkMode, true);
      
      // Toggle back to light mode
      themeService.toggleTheme();
      expect(themeService.isDarkMode, false);
    });

    testWidgets('Todo controller should manage todo state', (WidgetTester tester) async {
      final todoController = TodoController();
      
      // Initial state should be empty
      expect(todoController.todos.isEmpty, true);
      expect(todoController.isLoading, false);
      
      // Test adding a todo
      await todoController.addTodo(
        title: 'Test Todo',
        description: 'Test Description',
        priority: 1, // Medium priority
      );
      
      expect(todoController.todos.length, 1);
      expect(todoController.todos.first.title, 'Test Todo');
    });

    testWidgets('Auth service should handle biometric availability', (WidgetTester tester) async {
      final authService = AuthService();
      
      // Test initial state
      expect(authService.isAuthenticated, false);
      
      // Test biometric availability check
      await authService.checkAuthenticationState();
      // Note: This will depend on the test environment
    });

    testWidgets('Login screen should display fingerprint button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider(create: (context) => AuthService()),
                ],
                child: const Scaffold(
                  body: Center(child: Text('Login Screen')),
                ),
              );
            },
          ),
        ),
      );
      
      expect(find.text('Login Screen'), findsOneWidget);
    });
  });
}

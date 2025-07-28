import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoService {
  static const String _storageKey = 'todos';
  List<Todo> _todos = [];

  // Get all todos
  List<Todo> get todos => List.unmodifiable(_todos);

  // Get completed todos
  List<Todo> get completedTodos => _todos.where((todo) => todo.isCompleted).toList();

  // Get pending todos
  List<Todo> get pendingTodos => _todos.where((todo) => !todo.isCompleted).toList();

  // Get todos by priority
  List<Todo> getTodosByPriority(int priority) {
    return _todos.where((todo) => todo.priority == priority).toList();
  }

  // Load todos from storage
  Future<void> loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = prefs.getStringList(_storageKey) ?? [];
      
      _todos = todosJson
          .map((json) => Todo.fromMap(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading todos: $e');
      _todos = [];
    }
  }

  // Save todos to storage
  Future<void> saveTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = _todos
          .map((todo) => jsonEncode(todo.toMap()))
          .toList();
      
      await prefs.setStringList(_storageKey, todosJson);
    } catch (e) {
      print('Error saving todos: $e');
    }
  }

  // Add new todo
  Future<void> addTodo(Todo todo) async {
    _todos.add(todo);
    await saveTodos();
  }

  // Update existing todo
  Future<void> updateTodo(Todo updatedTodo) async {
    final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index != -1) {
      _todos[index] = updatedTodo;
      await saveTodos();
    }
  }

  // Delete todo
  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((todo) => todo.id == id);
    await saveTodos();
  }

  // Toggle todo completion
  Future<void> toggleTodoCompletion(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].toggleCompletion();
      await saveTodos();
    }
  }

  // Clear completed todos
  Future<void> clearCompletedTodos() async {
    _todos.removeWhere((todo) => todo.isCompleted);
    await saveTodos();
  }

  // Get todo by id
  Todo? getTodoById(String id) {
    try {
      return _todos.firstWhere((todo) => todo.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search todos by title
  List<Todo> searchTodos(String query) {
    if (query.isEmpty) return _todos;
    
    return _todos
        .where((todo) => 
            todo.title.toLowerCase().contains(query.toLowerCase()) ||
            todo.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Get todos count
  int get totalCount => _todos.length;
  int get completedCount => completedTodos.length;
  int get pendingCount => pendingTodos.length;

  // Get completion percentage
  double get completionPercentage {
    if (_todos.isEmpty) return 0.0;
    return (completedCount / totalCount) * 100;
  }
} 
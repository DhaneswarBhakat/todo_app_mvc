import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../services/api_service.dart';

class TodoController extends ChangeNotifier {
  
  List<Todo> _todos = [];
  List<Todo> _filteredTodos = [];
  String _searchQuery = '';
  TodoFilter _currentFilter = TodoFilter.all;
  bool _isLoading = false;

  // Getters
  List<Todo> get todos => _todos;
  List<Todo> get filteredTodos => _filteredTodos;
  String get searchQuery => _searchQuery;
  TodoFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  
  // Statistics
  int get totalCount => _todos.length;
  int get completedCount => _todos.where((todo) => todo.isCompleted).length;
  int get pendingCount => _todos.where((todo) => !todo.isCompleted).length;
  double get completionPercentage {
    if (_todos.isEmpty) return 0.0;
    return (completedCount / totalCount) * 100;
  }

  // Initialize controller
  Future<void> initialize() async {
    _setLoading(true);
    try {
      print('🔄 Fetching todos from API...');
      _todos = await ApiService.getTodos();
      print('✅ Loaded ${_todos.length} todos from API');
      _applyFilters();
    } catch (e) {
      print('❌ Error loading todos from API: $e');
      _todos = [];
    }
    _setLoading(false);
  }

  // Add new todo
  Future<void> addTodo({
    required String title,
    String description = '',
    int priority = 1,
  }) async {
    try {
      print('🔄 Creating todo via API...');
      final newTodo = await ApiService.createTodo(
        title: title.trim(),
        description: description.trim(),
        priority: priority,
      );
      print('✅ Todo created via API: ${newTodo.id}');
      
      // Refresh todos from API
      await refreshTodos();
    } catch (e) {
      print('❌ Error creating todo: $e');
      rethrow;
    }
  }

  // Update todo
  Future<void> updateTodo(Todo updatedTodo) async {
    try {
      print('🔄 Updating todo via API: ${updatedTodo.id}');
      await ApiService.updateTodo(
        id: updatedTodo.id,
        title: updatedTodo.title,
        description: updatedTodo.description,
        priority: updatedTodo.priority,
        category: updatedTodo.category,
      );
      print('✅ Todo updated via API');
      
      // Refresh todos from API
      await refreshTodos();
    } catch (e) {
      print('❌ Error updating todo: $e');
      rethrow;
    }
  }

  // Delete todo
  Future<void> deleteTodo(String id) async {
    try {
      print('🔄 Deleting todo via API: $id');
      await ApiService.deleteTodo(id);
      print('✅ Todo deleted via API');
      
      // Refresh todos from API
      await refreshTodos();
    } catch (e) {
      print('❌ Error deleting todo: $e');
      // If delete fails, still refresh to show current state
      await refreshTodos();
    }
  }

  // Toggle todo completion
  Future<void> toggleTodoCompletion(String id) async {
    try {
      print('🔄 Toggling todo completion via API: $id');
      await ApiService.toggleTodoCompletion(id);
      print('✅ Todo completion toggled via API');
      
      // Refresh todos from API
      await refreshTodos();
    } catch (e) {
      print('❌ Error toggling todo completion: $e');
      rethrow;
    }
  }

  // Clear completed todos
  Future<void> clearCompletedTodos() async {
    try {
      print('🔄 Clearing completed todos via API...');
      await ApiService.clearCompletedTodos();
      print('✅ Completed todos cleared via API');
      
      // Refresh todos from API
      await refreshTodos();
    } catch (e) {
      print('❌ Error clearing completed todos: $e');
      rethrow;
    }
  }

  // Search todos
  void searchTodos(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Set filter
  void setFilter(TodoFilter filter) {
    _currentFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters and search
  void _applyFilters() {
    List<Todo> filtered = List.from(_todos);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = _todos
          .where((todo) => 
              todo.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              todo.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply status filter
    switch (_currentFilter) {
      case TodoFilter.all:
        break;
      case TodoFilter.pending:
        filtered = filtered.where((todo) => !todo.isCompleted).toList();
        break;
      case TodoFilter.completed:
        filtered = filtered.where((todo) => todo.isCompleted).toList();
        break;
      case TodoFilter.highPriority:
        filtered = filtered.where((todo) => todo.priority == 3).toList();
        break;
    }

    // Sort by priority (high to low) and creation date (newest first)
    filtered.sort((a, b) {
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    _filteredTodos = filtered;
  }

  // Get todo by id
  Todo? getTodoById(String id) {
    try {
      return _todos.firstWhere((todo) => todo.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get todos by priority
  List<Todo> getTodosByPriority(int priority) {
    return _todos.where((todo) => todo.priority == priority).toList();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Refresh todos
  Future<void> refreshTodos() async {
    try {
      print('🔄 Refreshing todos from API...');
      _todos = await ApiService.getTodos();
      print('✅ Refreshed ${_todos.length} todos from API');
      _applyFilters();
      notifyListeners();
    } catch (e) {
      print('❌ Error refreshing todos: $e');
      rethrow;
    }
  }
}

// Filter enum
enum TodoFilter {
  all,
  pending,
  completed,
  highPriority,
}

// Extension for filter names
extension TodoFilterExtension on TodoFilter {
  String get displayName {
    switch (this) {
      case TodoFilter.all:
        return 'All';
      case TodoFilter.pending:
        return 'Pending';
      case TodoFilter.completed:
        return 'Completed';
      case TodoFilter.highPriority:
        return 'High Priority';
    }
  }
} 
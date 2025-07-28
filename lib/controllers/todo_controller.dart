import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';

class TodoController extends ChangeNotifier {
  final TodoService _todoService = TodoService();
  final Uuid _uuid = Uuid();
  
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
  int get totalCount => _todoService.totalCount;
  int get completedCount => _todoService.completedCount;
  int get pendingCount => _todoService.pendingCount;
  double get completionPercentage => _todoService.completionPercentage;

  // Initialize controller
  Future<void> initialize() async {
    _setLoading(true);
    await _todoService.loadTodos();
    _todos = _todoService.todos;
    _applyFilters();
    _setLoading(false);
  }

  // Add new todo
  Future<void> addTodo({
    required String title,
    String description = '',
    int priority = 1,
  }) async {
    final todo = Todo(
      id: _uuid.v4(),
      title: title.trim(),
      description: description.trim(),
      priority: priority,
      createdAt: DateTime.now(),
    );

    await _todoService.addTodo(todo);
    _todos = _todoService.todos;
    _applyFilters();
    notifyListeners();
  }

  // Update todo
  Future<void> updateTodo(Todo updatedTodo) async {
    await _todoService.updateTodo(updatedTodo);
    _todos = _todoService.todos;
    _applyFilters();
    notifyListeners();
  }

  // Delete todo
  Future<void> deleteTodo(String id) async {
    await _todoService.deleteTodo(id);
    _todos = _todoService.todos;
    _applyFilters();
    notifyListeners();
  }

  // Toggle todo completion
  Future<void> toggleTodoCompletion(String id) async {
    await _todoService.toggleTodoCompletion(id);
    _todos = _todoService.todos;
    _applyFilters();
    notifyListeners();
  }

  // Clear completed todos
  Future<void> clearCompletedTodos() async {
    await _todoService.clearCompletedTodos();
    _todos = _todoService.todos;
    _applyFilters();
    notifyListeners();
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
      filtered = _todoService.searchTodos(_searchQuery);
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
    return _todoService.getTodoById(id);
  }

  // Get todos by priority
  List<Todo> getTodosByPriority(int priority) {
    return _todoService.getTodosByPriority(priority);
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Refresh todos
  Future<void> refreshTodos() async {
    await initialize();
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
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';
import '../models/user.dart';

class ApiService {
  // Change this to your computer's IP address when testing on device/emulator
  // Use 'localhost' when testing on web
  // Use '10.0.2.2' when testing on Android emulator
  // Use your computer's IP (e.g., '192.168.1.100') when testing on physical device
  static const String baseUrl = 'http://10.155.78.76:3000/api'; // Your computer's IP
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  // HTTP client with timeout
  static final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 30);

  // Get stored auth token
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(authTokenKey);
  }

  // Store auth token
  static Future<void> _storeAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(authTokenKey, token);
  }

  // Store user data
  static Future<void> _storeUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userDataKey, jsonEncode(userData));
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(userDataKey);
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  // Clear stored data
  static Future<void> clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(authTokenKey);
    await prefs.remove(userDataKey);
  }

  // Helper method to make authenticated requests
  static Future<http.Response> _makeAuthenticatedRequest(
    String endpoint,
    String method, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      ...?headers,
    };

    switch (method.toUpperCase()) {
      case 'GET':
        return await _client
            .get(uri, headers: requestHeaders)
            .timeout(_timeout);
      case 'POST':
        return await _client
            .post(uri, headers: requestHeaders, body: jsonEncode(body))
            .timeout(_timeout);
      case 'PUT':
        return await _client
            .put(uri, headers: requestHeaders, body: jsonEncode(body))
            .timeout(_timeout);
      case 'PATCH':
        if (body != null) {
          return await _client
              .patch(uri, headers: requestHeaders, body: jsonEncode(body))
              .timeout(_timeout);
        } else {
          return await _client
              .patch(uri, headers: requestHeaders)
              .timeout(_timeout);
        }
      case 'DELETE':
        return await _client
            .delete(uri, headers: requestHeaders)
            .timeout(_timeout);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  // Authentication methods
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201 && data['success']) {
        await _storeAuthToken(data['data']['token']);
        await _storeUserData(data['data']['user']);
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        await _storeAuthToken(data['data']['token']);
        await _storeUserData(data['data']['user']);
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _makeAuthenticatedRequest('/auth/me', 'GET');
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return data['data']['user'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      throw Exception('Get profile error: $e');
    }
  }

  static Future<void> logout() async {
    try {
      await _makeAuthenticatedRequest('/auth/logout', 'POST');
    } catch (e) {
      // Continue with logout even if API call fails
      print('Logout API error: $e');
    } finally {
      await clearStoredData();
    }
  }

  // Todo methods
  static Future<List<Todo>> getTodos({
    bool? isCompleted,
    int? priority,
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (isCompleted != null) {
        queryParams['isCompleted'] = isCompleted.toString();
      }
      if (priority != null) {
        queryParams['priority'] = priority.toString();
      }
      if (category != null) {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = '/todos${queryString.isNotEmpty ? '?$queryString' : ''}';

      final response = await _makeAuthenticatedRequest(endpoint, 'GET');
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        final todosList = data['data']['todos'] as List;
        return todosList.map((todoJson) => Todo.fromMap(todoJson)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to get todos');
      }
    } catch (e) {
      throw Exception('Get todos error: $e');
    }
  }

  static Future<Todo> getTodo(String id) async {
    try {
      final response = await _makeAuthenticatedRequest('/todos/$id', 'GET');
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return Todo.fromMap(data['data']['todo']);
      } else {
        throw Exception(data['message'] ?? 'Failed to get todo');
      }
    } catch (e) {
      throw Exception('Get todo error: $e');
    }
  }

  static Future<Todo> createTodo({
    required String title,
    String description = '',
    int priority = 1,
    DateTime? dueDate,
    String category = 'General',
    List<String> tags = const [],
  }) async {
    try {
      print('🔍 Debug: Sending todo data to backend:');
      print('  - title: "$title" (${title.length} chars)');
      print('  - description: "$description" (${description.length} chars)');
      print('  - priority: $priority (type: ${priority.runtimeType})');
      print('  - category: "$category" (${category.length} chars)');
      print('  - tags: $tags');
      
      // Build request body, omitting null values
      final body = <String, dynamic>{
        'title': title.trim(),
        'description': description.trim(),
        'priority': priority,
        'category': category.trim(),
        'tags': tags,
      };
      
      // Only add dueDate if it's not null
      if (dueDate != null) {
        body['dueDate'] = dueDate.toIso8601String();
      }
      
      final response = await _makeAuthenticatedRequest('/todos', 'POST', body: body);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201 && data['success']) {
        return Todo.fromMap(data['data']['todo']);
      } else {
        // Log detailed validation errors
        print('❌ Backend response: $data');
        print('❌ Status code: ${response.statusCode}');
        
        if (data['errors'] != null && data['errors'] is List) {
          print('❌ Validation errors:');
          for (final error in data['errors']) {
            if (error is Map) {
              print('  - ${error['param']}: ${error['msg']}');
            }
          }
        }
        
        throw Exception(data['message'] ?? 'Failed to create todo');
      }
    } catch (e) {
      throw Exception('Create todo error: $e');
    }
  }

  static Future<Todo> updateTodo({
    required String id,
    String? title,
    String? description,
    int? priority,
    DateTime? dueDate,
    String? category,
    List<String>? tags,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (priority != null) body['priority'] = priority;
      if (dueDate != null) body['dueDate'] = dueDate.toIso8601String();
      if (category != null) body['category'] = category;
      if (tags != null) body['tags'] = tags;

      final response = await _makeAuthenticatedRequest('/todos/$id', 'PUT', body: body);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return Todo.fromMap(data['data']['todo']);
      } else {
        throw Exception(data['message'] ?? 'Failed to update todo');
      }
    } catch (e) {
      throw Exception('Update todo error: $e');
    }
  }

  static Future<Todo> toggleTodoCompletion(String id) async {
    try {
      print('🔍 Debug: Toggling todo with ID: $id');
      print('🔍 Debug: Making PATCH request to /todos/$id/toggle');
      
      final response = await _makeAuthenticatedRequest('/todos/$id/toggle', 'PATCH');
      
      print('🔍 Debug: Response status: ${response.statusCode}');
      print('🔍 Debug: Response body: ${response.body}');
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return Todo.fromMap(data['data']['todo']);
      } else {
        throw Exception(data['message'] ?? 'Failed to toggle todo');
      }
    } catch (e) {
      print('❌ Debug: Error in toggleTodoCompletion: $e');
      throw Exception('Toggle todo error: $e');
    }
  }

  static Future<void> deleteTodo(String id) async {
    try {
      final response = await _makeAuthenticatedRequest('/todos/$id', 'DELETE');
      final data = jsonDecode(response.body);
      
      if (response.statusCode != 200 || !data['success']) {
        throw Exception(data['message'] ?? 'Failed to delete todo');
      }
    } catch (e) {
      throw Exception('Delete todo error: $e');
    }
  }

  static Future<void> clearCompletedTodos() async {
    try {
      final response = await _makeAuthenticatedRequest('/todos/clear-completed', 'DELETE');
      final data = jsonDecode(response.body);
      
      if (response.statusCode != 200 || !data['success']) {
        throw Exception(data['message'] ?? 'Failed to clear completed todos');
      }
    } catch (e) {
      throw Exception('Clear completed todos error: $e');
    }
  }

  static Future<Map<String, dynamic>> getTodoStats() async {
    try {
      final response = await _makeAuthenticatedRequest('/todos/stats/summary', 'GET');
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return data['data']['stats'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get todo stats');
      }
    } catch (e) {
      throw Exception('Get todo stats error: $e');
    }
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await _getAuthToken();
    if (token == null) return false;

    try {
      await getProfile();
      return true;
    } catch (e) {
      await clearStoredData();
      return false;
    }
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> getUserData() async {
    return await _getUserData();
  }

  // Dispose HTTP client
  static void dispose() {
    _client.close();
  }
}

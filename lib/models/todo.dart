class Todo {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final int priority; // 1: Low, 2: Medium, 3: High
  final String category;
  final DateTime? dueDate;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = 1,
    this.category = 'General',
    this.dueDate,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  // Convert Todo to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority,
      'category': category,
      'dueDate': dueDate?.toIso8601String(),
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // Create Todo from Map (from API response)
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['_id'] ?? map['id'], // Handle both MongoDB _id and regular id
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      priority: map['priority'] ?? 1,
      category: map['category'] ?? 'General',
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    );
  }

  // Copy with method for immutable updates
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    int? priority,
    String? category,
    DateTime? dueDate,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Toggle completion status
  Todo toggleCompletion() {
    return copyWith(
      isCompleted: !isCompleted,
      completedAt: !isCompleted ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );
  }

  // Get priority string
  String get priorityString {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return 'Low';
    }
  }

  // Get priority color
  int get priorityColor {
    switch (priority) {
      case 1:
        return 0xFF4CAF50; // Green
      case 2:
        return 0xFFFF9800; // Orange
      case 3:
        return 0xFFF44336; // Red
      default:
        return 0xFF4CAF50; // Green
    }
  }

  // Check if todo is overdue
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  // Get days until due
  int? get daysUntilDue {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final today = DateTime(now.year, now.month, now.day);
    return due.difference(today).inDays;
  }

  // Get due date string
  String? get dueDateString {
    if (dueDate == null) return null;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    
    if (due == today) return 'Today';
    if (due == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (due == today.subtract(const Duration(days: 1))) return 'Yesterday';
    
    return '${due.day}/${due.month}/${due.year}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, isCompleted: $isCompleted, priority: $priority)';
  }
} 
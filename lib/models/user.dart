class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final bool isActive;
  final DateTime? lastLogin;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.isActive = true,
    this.lastLogin,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert User to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'isActive': isActive,
      'lastLogin': lastLogin?.toIso8601String(),
      'preferences': preferences.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create User from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatar: map['avatar'],
      isActive: map['isActive'] ?? true,
      lastLogin: map['lastLogin'] != null 
          ? DateTime.parse(map['lastLogin']) 
          : null,
      preferences: UserPreferences.fromMap(map['preferences'] ?? {}),
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : DateTime.now(),
    );
  }

  // Copy with method for immutable updates
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    bool? isActive,
    DateTime? lastLogin,
    UserPreferences? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get display name (full name or email fallback)
  String get displayName => name.isNotEmpty ? name : email;

  // Get initials for avatar
  String get initials {
    if (name.isEmpty) return email.substring(0, 2).toUpperCase();
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class UserPreferences {
  final String theme;
  final bool notifications;

  const UserPreferences({
    this.theme = 'auto',
    this.notifications = true,
  });

  // Convert UserPreferences to Map
  Map<String, dynamic> toMap() {
    return {
      'theme': theme,
      'notifications': notifications,
    };
  }

  // Create UserPreferences from Map
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      theme: map['theme'] ?? 'auto',
      notifications: map['notifications'] ?? true,
    );
  }

  // Copy with method
  UserPreferences copyWith({
    String? theme,
    bool? notifications,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
    );
  }

  // Get theme mode for Flutter
  String get themeMode {
    switch (theme) {
      case 'light':
        return 'light';
      case 'dark':
        return 'dark';
      case 'auto':
      default:
        return 'system';
    }
  }

  @override
  String toString() {
    return 'UserPreferences(theme: $theme, notifications: $notifications)';
  }
}

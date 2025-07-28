# Todo App MVC

A Flutter todo application built using the MVC (Model-View-Controller) architecture pattern. This app demonstrates clean separation of concerns and follows Flutter best practices.

## Features

- ✅ Create, read, update, and delete todos
- 🔍 Search todos by title or description
- 🏷️ Filter todos by status (All, Pending, Completed, High Priority)
- ⭐ Priority levels (Low, Medium, High) with color coding
- 📊 Statistics dashboard with completion percentage
- 💾 Local storage using SharedPreferences
- 🎨 Modern Material Design 3 UI
- 📱 Responsive design for different screen sizes

## MVC Architecture

### Model Layer (`lib/models/`)
- **`todo.dart`**: Defines the Todo data model with properties like id, title, description, completion status, priority, and timestamps.

### View Layer (`lib/views/`)
- **`main_app.dart`**: Root application widget with theme configuration
- **`todo_list_screen.dart`**: Main screen displaying todos with search and filter functionality
- **`add_todo_screen.dart`**: Screen for creating new todos
- **`todo_detail_screen.dart`**: Screen for viewing and editing todo details

### Controller Layer (`lib/controllers/`)
- **`todo_controller.dart`**: Manages business logic, state, and communication between Model and View layers

### Service Layer (`lib/services/`)
- **`todo_service.dart`**: Handles data operations and persistence using SharedPreferences

### Utils (`lib/utils/`)
- **`todo_widgets.dart`**: Reusable UI components like TodoCard, PrioritySelector, and TodoStatsCard

## Project Structure

```
lib/
├── models/
│   └── todo.dart
├── views/
│   ├── main_app.dart
│   ├── todo_list_screen.dart
│   ├── add_todo_screen.dart
│   └── todo_detail_screen.dart
├── controllers/
│   └── todo_controller.dart
├── services/
│   └── todo_service.dart
├── utils/
│   └── todo_widgets.dart
└── main.dart
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.4.1)
- Dart SDK (>=3.4.1)

### Installation

1. Clone the repository or navigate to the project directory
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

- **provider**: State management
- **shared_preferences**: Local data storage
- **uuid**: Unique ID generation

## How to Use

1. **Adding Todos**: Tap the floating action button (+) to create a new todo
2. **Viewing Todos**: All todos are displayed on the main screen with priority indicators
3. **Searching**: Use the search bar to find specific todos
4. **Filtering**: Use the filter chips to view todos by status or priority
5. **Editing**: Tap on a todo to view details and edit
6. **Completing**: Use the checkbox or toggle button to mark todos as complete
7. **Deleting**: Use the delete button to remove todos

## MVC Benefits in This App

### Separation of Concerns
- **Model**: Pure data structure with business logic methods
- **View**: UI components that display data and handle user interactions
- **Controller**: Orchestrates between Model and View, manages state

### Maintainability
- Easy to modify individual components without affecting others
- Clear responsibility boundaries
- Testable architecture

### Scalability
- Easy to add new features
- Modular design allows for easy extension
- Reusable components

## Key Features Implementation

### State Management
- Uses Provider pattern for state management
- Controller extends ChangeNotifier for reactive updates
- Automatic UI updates when data changes

### Data Persistence
- SharedPreferences for local storage
- JSON serialization/deserialization
- Automatic save/load operations

### UI/UX
- Material Design 3 components
- Responsive layout
- Intuitive navigation
- Visual feedback for user actions

## Contributing

Feel free to contribute to this project by:
- Reporting bugs
- Suggesting new features
- Submitting pull requests

## License

This project is open source and available under the [MIT License](LICENSE).

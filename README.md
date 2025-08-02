# Todo App MVC with Fingerprint Authentication

A secure Flutter todo application built using the MVC (Model-View-Controller) architecture pattern with biometric authentication.

## Features

### 🔐 Security Features
- **Fingerprint Authentication**: Secure access to your todos using biometric authentication
- **Auto-logout**: Automatic logout when app is closed for enhanced security
- **Authentication State Management**: Persistent authentication state with secure storage

### 📝 Todo Management
- Create, read, update, and delete todos
- Mark todos as complete/incomplete
- Search and filter todos
- Statistics dashboard showing todo counts
- Beautiful and intuitive UI

### 🎨 User Experience
- Dark/Light theme support
- Smooth animations and transitions
- Responsive design
- Modern Material Design 3

### ⚙️ Settings & Configuration
- Biometric authentication toggle
- Theme preferences
- App settings management

## Architecture

This app follows the MVC (Model-View-Controller) pattern:

### Models (`lib/models/`)
- `todo.dart`: Todo data model with properties like id, title, description, completion status, etc.

### Views (`lib/views/`)
- `login_screen.dart`: Fingerprint authentication screen
- `todo_list_screen.dart`: Main todo list with search and filter functionality
- `add_todo_screen.dart`: Screen for adding new todos
- `todo_detail_screen.dart`: Detailed view of individual todos
- `settings_screen.dart`: App settings and authentication management
- `splash_screen.dart`: App loading screen

### Controllers (`lib/controllers/`)
- `todo_controller.dart`: Manages todo business logic, CRUD operations, and state

### Services (`lib/services/`)
- `auth_service.dart`: Handles biometric authentication using local_auth
- `todo_service.dart`: Data persistence and storage operations
- `theme_service.dart`: Theme management and preferences

### Utils (`lib/utils/`)
- `todo_widgets.dart`: Reusable UI components

## Getting Started

### Prerequisites
- Flutter SDK (>=3.4.1)
- Android Studio / VS Code
- Android device with fingerprint sensor (for testing biometric features)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd todo_app_mvc
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Biometric Authentication Setup

1. **First Launch**: The app will show the login screen with fingerprint authentication
2. **Enable Authentication**: Tap the fingerprint button to authenticate
3. **Settings**: Access settings via the gear icon to manage authentication preferences
4. **Logout**: Use the logout button to sign out and require re-authentication

## Dependencies

- `local_auth`: Biometric authentication
- `shared_preferences`: Local data storage
- `provider`: State management
- `uuid`: Unique ID generation

## Android Permissions

The app requires the following Android permissions for biometric authentication:

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

## Security Features

### Biometric Authentication
- Uses device's fingerprint sensor for secure access
- Supports both fingerprint and face recognition (where available)
- Secure storage of authentication state
- Automatic logout for enhanced security

### Data Protection
- Local storage only - no data sent to external servers
- Secure authentication state management
- User-controlled authentication preferences

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support or questions about the fingerprint authentication feature, please open an issue in the repository.

# Todo App MVC - Full Stack Flutter Project

A secure, full-stack todo application built with **Flutter (Frontend)** and **Node.js + Express + MongoDB (Backend)**, featuring biometric authentication, theme switching, and cloud data persistence.

## 🏗️ Full-Stack Architecture

This project follows a **client-server architecture** with:

### Frontend (Flutter)
- **Framework**: Flutter with MVC pattern
- **State Management**: Provider package
- **Authentication**: Biometric + JWT tokens
- **Local Storage**: SharedPreferences for offline support

### Backend (Node.js)
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT (JSON Web Tokens)
- **Security**: Helmet, CORS, Rate Limiting

## 📁 Project Structure

```
todo_app_mvc/
├── lib/                    # Flutter frontend
│   ├── main.dart          # App entry point
│   ├── models/            # Data models
│   ├── views/             # UI screens
│   ├── controllers/       # Business logic
│   ├── services/          # API & local services
│   └── utils/             # Shared components
├── backend/               # Node.js backend
│   ├── src/               # Source code
│   │   ├── config/        # Database & config
│   │   ├── middleware/    # Auth & validation
│   │   ├── models/        # MongoDB schemas
│   │   ├── routes/        # API endpoints
│   │   └── server.js      # Express server
│   ├── package.json       # Dependencies
│   └── README.md          # Backend docs
└── README.md              # This file
```

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.4.1+
- Node.js 18+
- MongoDB instance
- Git

### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment**
   ```bash
   cp env.example .env
   # Edit .env with your MongoDB connection
   ```

4. **Start backend server**
   ```bash
   npm run dev
   # Server runs on http://localhost:3000
   ```

### Frontend Setup

1. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

2. **Update API configuration** (if needed)
   - Edit `lib/services/api_service.dart`
   - Update `baseUrl` if backend runs on different port

3. **Run Flutter app**
   ```bash
   flutter run
   ```

## 🔄 Data Flow

### Authentication Flow
1. **User opens app** → Biometric authentication
2. **Success** → JWT token stored locally
3. **API calls** → Token included in headers
4. **Backend validates** → JWT verification
5. **Response** → Data returned to Flutter

### Todo Operations
1. **User action** → Flutter controller
2. **Controller** → API service call
3. **API service** → HTTP request to backend
4. **Backend** → MongoDB operation
5. **Response** → Data synced to Flutter state

## 📱 Key Features

### Frontend (Flutter)
- **Biometric Authentication**: Fingerprint/face recognition
- **Responsive Design**: Mobile and tablet support
- **Theme Switching**: Light/dark mode
- **Offline Support**: Local storage fallback
- **Real-time Sync**: Automatic data synchronization

### Backend (Node.js)
- **RESTful API**: Complete CRUD operations
- **JWT Authentication**: Secure token-based auth
- **Data Validation**: Input sanitization
- **Rate Limiting**: API abuse prevention
- **MongoDB Integration**: Scalable data storage

## 🔐 Security Features

### Frontend Security
- Biometric authentication
- Secure token storage
- Input validation
- HTTPS enforcement

### Backend Security
- JWT token validation
- Password hashing (bcrypt)
- Rate limiting
- CORS protection
- Helmet security headers

## 🌐 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get profile
- `PUT /api/auth/profile` - Update profile

### Todos
- `GET /api/todos` - List todos (with filters)
- `POST /api/todos` - Create todo
- `PUT /api/todos/:id` - Update todo
- `DELETE /api/todos/:id` - Delete todo
- `PATCH /api/todos/:id/toggle` - Toggle completion

## 📊 Database Schema

### User Collection
```javascript
{
  email: String (unique),
  password: String (hashed),
  name: String,
  preferences: {
    theme: String,
    notifications: Boolean
  },
  timestamps: true
}
```

### Todo Collection
```javascript
{
  user: ObjectId (ref: User),
  title: String,
  description: String,
  isCompleted: Boolean,
  priority: Number (1-3),
  dueDate: Date,
  category: String,
  tags: [String],
  timestamps: true
}
```

## 🛠️ Development

### Backend Development
```bash
cd backend
npm run dev          # Development with auto-reload
npm test            # Run tests
npm run migrate     # Database migrations
```

### Frontend Development
```bash
flutter pub get     # Install dependencies
flutter run         # Run app
flutter build apk   # Build Android APK
flutter build ios   # Build iOS app
```

### Environment Configuration
- **Development**: `http://localhost:3000`
- **Production**: Update `baseUrl` in `api_service.dart`
- **MongoDB**: Local or MongoDB Atlas

## 🚀 Deployment

### Backend Deployment
1. **Environment setup**
   ```bash
   NODE_ENV=production
   MONGODB_URI_PROD=mongodb+srv://...
   JWT_SECRET=strong-secret-key
   ```

2. **Start production server**
   ```bash
   npm start
   ```

### Frontend Deployment
1. **Update API endpoint** in `api_service.dart`
2. **Build platform-specific packages**
   ```bash
   flutter build apk --release
   flutter build ios --release
   ```

## 🔍 Monitoring & Debugging

### Backend Health Check
```
GET http://localhost:3000/health
```

### API Testing
- Use Postman or Insomnia
- Include JWT token in Authorization header
- Test all CRUD operations

### Flutter Debug
- Use Flutter DevTools
- Check network requests
- Monitor local storage

## 📚 Documentation

- **Frontend**: See inline code comments
- **Backend**: See `backend/README.md`
- **API**: Complete endpoint documentation
- **Database**: Schema and relationships

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Follow coding standards
4. Add tests for new features
5. Submit pull request

## 🔮 Future Enhancements

### Frontend
- Push notifications
- Widget support
- Advanced filtering
- Data export/import

### Backend
- GraphQL API
- Real-time WebSocket support
- File upload service
- Advanced analytics

### Infrastructure
- Docker containerization
- CI/CD pipeline
- Automated testing
- Performance monitoring

## 📄 License

This project is for educational and personal use.

---

**Built with Flutter, Node.js, Express, and MongoDB for modern full-stack mobile development.**

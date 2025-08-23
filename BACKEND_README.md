# Todo App Backend - Node.js + Express + MongoDB

A robust REST API backend for the Todo App MVC Flutter application, built with Node.js, Express, and MongoDB.

## 🏗️ Architecture Overview

The backend is built with **Node.js + Express + MongoDB** using a clean, modular architecture:

- **Runtime**: Node.js 18+
- **Framework**: Express.js with middleware-based architecture
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT (JSON Web Tokens)
- **Security**: Helmet, CORS, rate limiting, bcrypt password hashing

## 📁 Project Structure

```
backend/
├── src/
│   ├── config/
│   │   └── database.js          # MongoDB connection configuration
│   ├── middleware/
│   │   ├── auth.js              # JWT authentication middleware
│   │   └── errorHandler.js      # Global error handling
│   ├── models/
│   │   ├── User.js              # User data model
│   │   └── Todo.js              # Todo data model
│   ├── routes/
│   │   ├── auth.js              # Authentication routes
│   │   ├── todos.js             # Todo CRUD routes
│   │   └── users.js             # User management routes
│   └── server.js                # Main application entry point
├── .env                         # Environment variables
├── package.json                 # Dependencies and scripts
└── README.md                    # Backend documentation
```

## 🚀 Core Components

### 1. Server Entry Point (`server.js`)

The main application file that:
- Sets up Express server with security middleware (Helmet, CORS, compression)
- Configures rate limiting (100 requests per 15 minutes)
- Implements health check endpoint at `/health`
- Routes API endpoints under `/api/` prefix
- Handles graceful shutdown on SIGTERM/SIGINT

**Key Features:**
```javascript
// Security middleware
app.use(helmet());
app.use(compression());

// CORS configuration
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? ['https://yourdomain.com'] 
    : ['http://localhost:3000', 'http://localhost:8080'],
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
});
```

### 2. Database Configuration (`config/database.js`)

Manages MongoDB connection with:
- Environment-based URI selection (development vs production)
- Connection pooling and timeout configurations
- Connection event handling (error, disconnect, reconnect)
- Automatic database selection based on NODE_ENV

```javascript
const connectDB = async () => {
  const mongoURI = process.env.NODE_ENV === "production"
    ? process.env.MONGODB_URI_PROD
    : process.env.MONGODB_URI;

  const conn = await mongoose.connect(mongoURI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
    maxPoolSize: 10,
    serverSelectionTimeoutMS: 5000,
    socketTimeoutMS: 45000,
  });
};
```

### 3. Data Models

#### User Model (`models/User.js`)

```javascript
{
  email: String (unique, validated),
  password: String (bcrypt hashed),
  name: String (required),
  avatar: String (optional),
  isActive: Boolean,
  lastLogin: Date,
  preferences: {
    theme: 'light'|'dark'|'auto',
    notifications: Boolean
  }
}
```

**Features:**
- Automatic password hashing with bcrypt (12 rounds)
- Email validation with regex pattern
- Public profile method (excludes sensitive data)
- Static method for email lookup
- Virtual properties for computed fields

#### Todo Model (`models/Todo.js`)

```javascript
{
  user: ObjectId (ref: User),
  title: String (required, max 200 chars),
  description: String (max 1000 chars),
  isCompleted: Boolean,
  priority: Number (1-3: Low/Medium/High),
  dueDate: Date,
  category: String,
  tags: [String],
  attachments: [Object],
  sharedWith: [Object],
  notes: [Object]
}
```

**Advanced Features:**
- Virtual properties for status, priority strings, and overdue detection
- Database indexes for optimal query performance
- Static methods for user-specific queries and statistics
- Aggregation pipeline for user statistics

**Virtual Properties:**
```javascript
// Virtual for overdue status
todoSchema.virtual('isOverdue').get(function() {
  if (!this.dueDate || this.isCompleted) return false;
  return new Date() > this.dueDate;
});

// Virtual for priority string
todoSchema.virtual('priorityString').get(function() {
  const priorities = { 1: 'Low', 2: 'Medium', 3: 'High' };
  return priorities[this.priority] || 'Low';
});
```

### 4. Authentication Middleware (`middleware/auth.js`)

Comprehensive authentication system with:
- **JWT verification**: Validates Bearer tokens from Authorization header
- **User validation**: Ensures user exists and is active
- **Optional auth**: For routes that work with/without authentication
- **Admin role checking**: For admin-only endpoints
- **Rate limiting**: Special limits for auth routes (5 requests per 15 minutes)

```javascript
const auth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. No token provided.'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.userId).select('-password');
    
    if (!user || !user.isActive) {
      return res.status(401).json({
        success: false,
        message: 'Invalid token or inactive user.'
      });
    }

    req.user = user;
    next();
  } catch (error) {
    // Handle JWT errors (expired, invalid, etc.)
  }
};
```

## 🔌 API Endpoints

### Base URL
```
http://localhost:3000/api
```

### Authentication Routes (`/api/auth`)

#### POST `/auth/register`
Register a new user account.

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "user_id",
      "name": "John Doe",
      "email": "john@example.com",
      "preferences": {
        "theme": "auto",
        "notifications": true
      }
    },
    "token": "jwt_token_here"
  }
}
```

#### POST `/auth/login`
Authenticate existing user.

#### GET `/auth/me`
Get current user profile (requires authentication).

#### PUT `/auth/profile`
Update user profile (requires authentication).

### Todo Routes (`/api/todos`)

All todo endpoints require authentication via JWT token.

#### GET `/todos`
Get all todos for authenticated user with advanced filtering.

**Query Parameters:**
- `isCompleted` (boolean): Filter by completion status
- `priority` (1-3): Filter by priority level
- `category` (string): Filter by category
- `search` (string): Search in title and description
- `page` (number): Page number for pagination
- `limit` (number): Items per page (max 100)

**Response:**
```json
{
  "success": true,
  "data": {
    "todos": [...],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45,
      "pages": 3
    },
    "stats": {
      "total": 45,
      "completed": 12,
      "pending": 33,
      "highPriority": 5,
      "overdue": 2,
      "completionPercentage": 26.67
    }
  }
}
```

#### POST `/todos`
Create a new todo.

#### PUT `/todos/:id`
Update an existing todo.

#### PATCH `/todos/:id/toggle`
Toggle todo completion status.

#### DELETE `/todos/:id`
Delete a todo.

#### DELETE `/todos/clear-completed`
Clear all completed todos for the user.

#### GET `/todos/stats/summary`
Get todo statistics summary.

### User Routes (`/api/users`)
User profile and preferences management.

## 🔐 Security Features

### Authentication & Authorization
- **JWT Tokens**: Stateless authentication with configurable expiration
- **Password Hashing**: bcrypt with 12 rounds (configurable)
- **Token Validation**: Comprehensive JWT verification with error handling
- **User Status Check**: Active user validation

### Rate Limiting
- **General API**: 100 requests per 15 minutes per IP
- **Auth Routes**: 5 requests per 15 minutes per IP
- **Configurable**: Via environment variables

### Input Validation & Security
- **Express Validator**: Request body validation
- **Mongoose Validation**: Schema-level data validation
- **SQL Injection Protection**: Via Mongoose ODM
- **XSS Protection**: Via Helmet middleware
- **CORS Configuration**: Configurable origins for production

### Security Headers
```javascript
app.use(helmet()); // Security headers
app.use(compression()); // Response compression
```

## 📊 Database Optimization

### Indexing Strategy
```javascript
// User indexes
userSchema.index({ email: 1 });
userSchema.index({ createdAt: -1 });

// Todo indexes
todoSchema.index({ user: 1, createdAt: -1 });
todoSchema.index({ user: 1, isCompleted: 1 });
todoSchema.index({ user: 1, priority: -1 });
todoSchema.index({ user: 1, dueDate: 1 });
todoSchema.index({ user: 1, category: 1 });
```

### Aggregation Pipeline
Complex statistics calculation using MongoDB aggregation:

```javascript
todoSchema.statics.getUserStats = async function(userId) {
  const stats = await this.aggregate([
    { $match: { user: new mongoose.Types.ObjectId(userId) } },
    {
      $group: {
        _id: null,
        total: { $sum: 1 },
        completed: { $sum: { $cond: ['$isCompleted', 1, 0] } },
        pending: { $sum: { $cond: ['$isCompleted', 0, 1] } },
        highPriority: { $sum: { $cond: [{ $eq: ['$priority', 3] }, 1, 0] } },
        overdue: {
          $sum: {
            $cond: [
              { $and: [
                { $ne: ['$dueDate', null] }, 
                { $gt: [new Date(), '$dueDate'] }, 
                { $eq: ['$isCompleted', false] }
              ]},
              1, 0
            ]
          }
        }
      }
    }
  ]);
};
```

## ⚙️ Environment Configuration

### Required Environment Variables

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# MongoDB Connection
MONGODB_URI=mongodb://localhost:27017/todo_app
MONGODB_URI_PROD=mongodb+srv://username:password@cluster.mongodb.net/todo_app

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-here
JWT_EXPIRES_IN=7d

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Security
BCRYPT_ROUNDS=12
```

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ installed
- MongoDB instance running (local or cloud)

### Installation

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Environment setup**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Start the server**
   ```bash
   # Development mode with auto-reload
   npm run dev
   
   # Production mode
   npm start
   ```

### Health Check
```
GET http://localhost:3000/health
```

## 🔧 Integration with Flutter App

The backend serves your Flutter app by providing:

- **User Authentication**: Login/register with JWT tokens
- **Todo CRUD Operations**: Create, read, update, delete todos
- **Real-time Statistics**: Completion rates, overdue items, priority distribution
- **Advanced Filtering**: Search, category, priority filtering
- **User Preferences**: Theme and notification settings
- **Offline Sync**: API endpoints for data synchronization

## 📈 Performance Features

- **Connection Pooling**: MongoDB connection pool management
- **Response Compression**: Gzip compression for API responses
- **Efficient Queries**: Optimized database queries with proper indexing
- **Pagination**: Large dataset handling with pagination
- **Caching Headers**: Appropriate cache control headers

## 🛠️ Development

### Available Scripts
```bash
npm start          # Start production server
npm run dev        # Start development server with nodemon
npm test           # Run tests
npm run migrate    # Run database migrations
```

### Error Handling
- Centralized error handling middleware
- Consistent error response format
- Detailed error logging in development
- Graceful error responses in production

This backend provides a robust, scalable foundation for your Flutter todo app with enterprise-level security, performance optimizations, and comprehensive API documentation.

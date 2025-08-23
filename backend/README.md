# Todo App Backend - Node.js + Express + MongoDB

A robust REST API backend for the Todo App MVC Flutter application, built with Node.js, Express, and MongoDB.

## 🏗️ Architecture

- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT (JSON Web Tokens)
- **Validation**: Express-validator
- **Security**: Helmet, CORS, Rate Limiting
- **Logging**: Morgan

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ installed
- MongoDB instance running (local or cloud)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd todo_app_mvc/backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Environment setup**
   ```bash
   # Copy environment template
   cp env.example .env
   
   # Edit .env with your configuration
   nano .env
   ```

4. **Start the server**
   ```bash
   # Development mode with auto-reload
   npm run dev
   
   # Production mode
   npm start
   ```

## ⚙️ Configuration

### Environment Variables

Create a `.env` file in the backend directory:

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

### MongoDB Setup

#### Local MongoDB
```bash
# Install MongoDB (Ubuntu/Debian)
sudo apt update
sudo apt install mongodb

# Start MongoDB service
sudo systemctl start mongodb
sudo systemctl enable mongodb

# Create database
mongosh
use todo_app
```

#### MongoDB Atlas (Cloud)
1. Create account at [MongoDB Atlas](https://www.mongodb.com/atlas)
2. Create a new cluster
3. Get connection string
4. Update `MONGODB_URI_PROD` in `.env`

## 📚 API Documentation

### Base URL
```
http://localhost:3000/api
```

### Authentication Endpoints

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

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": { ... },
    "token": "jwt_token_here"
  }
}
```

#### GET `/auth/me`
Get current user profile (requires authentication).

**Headers:**
```
Authorization: Bearer <jwt_token>
```

#### PUT `/auth/profile`
Update user profile (requires authentication).

**Request Body:**
```json
{
  "name": "John Smith",
  "preferences": {
    "theme": "dark",
    "notifications": false
  }
}
```

### Todo Endpoints

All todo endpoints require authentication via JWT token.

#### GET `/todos`
Get all todos for authenticated user.

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

**Request Body:**
```json
{
  "title": "Complete project documentation",
  "description": "Write comprehensive API docs",
  "priority": 3,
  "dueDate": "2024-01-15T23:59:59.000Z",
  "category": "Work",
  "tags": ["documentation", "api"]
}
```

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

## 🔐 Authentication

### JWT Token Usage

Include the JWT token in the `Authorization` header:

```
Authorization: Bearer <your_jwt_token>
```

### Token Expiration

- Default expiration: 7 days
- Configurable via `JWT_EXPIRES_IN` environment variable
- Use `/auth/refresh` to get a new token

## 🛡️ Security Features

### Rate Limiting
- **Auth routes**: 5 requests per 15 minutes
- **General API**: 100 requests per 15 minutes

### Input Validation
- Request body validation using express-validator
- SQL injection protection via Mongoose
- XSS protection via Helmet

### CORS Configuration
- Configurable origins for production
- Credentials support for authenticated requests

## 📊 Database Models

### User Schema
```javascript
{
  email: String (unique, required),
  password: String (hashed, required),
  name: String (required),
  avatar: String (optional),
  isActive: Boolean (default: true),
  lastLogin: Date,
  preferences: {
    theme: String (light/dark/auto),
    notifications: Boolean
  },
  timestamps: true
}
```

### Todo Schema
```javascript
{
  user: ObjectId (ref: User, required),
  title: String (required, max 200),
  description: String (max 1000),
  isCompleted: Boolean (default: false),
  priority: Number (1-3, default: 1),
  dueDate: Date (optional),
  category: String (max 50),
  tags: [String] (max 10),
  attachments: [{
    filename: String,
    url: String,
    size: Number,
    type: String
  }],
  sharedWith: [{
    user: ObjectId (ref: User),
    permission: String (read/write/admin)
  }],
  notes: [{
    content: String,
    createdBy: ObjectId (ref: User),
    createdAt: Date
  }],
  timestamps: true
}
```

## 🧪 Testing

### Run Tests
```bash
npm test
```

### Test Coverage
```bash
npm run test:coverage
```

## 🚀 Deployment

### Production Checklist
- [ ] Set `NODE_ENV=production`
- [ ] Use strong `JWT_SECRET`
- [ ] Configure MongoDB Atlas connection
- [ ] Set up environment-specific CORS origins
- [ ] Enable compression and security headers
- [ ] Set up monitoring and logging

### Docker Deployment
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### Environment Variables for Production
```env
NODE_ENV=production
PORT=3000
MONGODB_URI_PROD=mongodb+srv://...
JWT_SECRET=very-long-random-secret-key
RATE_LIMIT_MAX_REQUESTS=1000
```

## 📝 Development

### Code Structure
```
src/
├── config/          # Configuration files
├── middleware/      # Custom middleware
├── models/          # Mongoose models
├── routes/          # API route handlers
├── server.js        # Main application file
└── utils/           # Utility functions
```

### Adding New Routes
1. Create route file in `src/routes/`
2. Import and use in `server.js`
3. Add validation middleware
4. Implement error handling

### Database Migrations
```bash
npm run migrate
```

## 🔍 Monitoring & Debugging

### Health Check
```
GET /health
```

### Logging
- Development: Morgan HTTP request logging
- Production: Structured logging recommended

### Error Handling
- Centralized error handling middleware
- Consistent error response format
- Detailed error logging in development

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Follow coding standards
4. Add tests for new features
5. Submit pull request

## 📄 License

MIT License - see LICENSE file for details.

---

**Built with Node.js, Express, and MongoDB for scalable, secure API development.**

#!/bin/bash

# Todo App Backend Startup Script
# This script helps you start the backend server with proper configuration

echo "🚀 Starting Todo App Backend..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js version 18+ is required. Current version: $(node -v)"
    exit 1
fi

echo "✅ Node.js version: $(node -v)"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating from template..."
    if [ -f env.example ]; then
        cp env.example .env
        echo "✅ .env file created from template."
        echo "📝 Please edit .env file with your configuration before starting the server."
        echo "   - Set your MongoDB connection string"
        echo "   - Set a strong JWT secret"
        echo "   - Configure other settings as needed"
        exit 1
    else
        echo "❌ env.example file not found. Please create .env file manually."
        exit 1
    fi
fi

# Check if dependencies are installed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install dependencies."
        exit 1
    fi
    echo "✅ Dependencies installed successfully."
fi

# Check environment
if [ "$NODE_ENV" = "production" ]; then
    echo "🏭 Starting in PRODUCTION mode..."
    npm start
else
    echo "🔧 Starting in DEVELOPMENT mode..."
    echo "   - Auto-reload enabled"
    echo "   - Debug logging enabled"
    echo "   - Server will restart on file changes"
    npm run dev
fi

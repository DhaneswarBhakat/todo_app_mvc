const mongoose = require('mongoose');

const todoSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required']
  },
  title: {
    type: String,
    required: [true, 'Title is required'],
    trim: true,
    maxlength: [200, 'Title cannot exceed 200 characters']
  },
  description: {
    type: String,
    trim: true,
    maxlength: [1000, 'Description cannot exceed 1000 characters'],
    default: ''
  },
  isCompleted: {
    type: Boolean,
    default: false
  },
  priority: {
    type: Number,
    enum: [1, 2, 3], // 1: Low, 2: Medium, 3: High
    default: 1
  },
  dueDate: {
    type: Date,
    default: null
  },
  tags: [{
    type: String,
    trim: true,
    maxlength: [20, 'Tag cannot exceed 20 characters']
  }],
  category: {
    type: String,
    trim: true,
    maxlength: [50, 'Category cannot exceed 50 characters'],
    default: 'General'
  },
  attachments: [{
    filename: String,
    url: String,
    size: Number,
    type: String
  }],
  sharedWith: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    permission: {
      type: String,
      enum: ['read', 'write', 'admin'],
      default: 'read'
    }
  }],
  notes: [{
    content: String,
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
  }]
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for completion status
todoSchema.virtual('status').get(function() {
  return this.isCompleted ? 'completed' : 'pending';
});

// Virtual for priority string
todoSchema.virtual('priorityString').get(function() {
  const priorities = { 1: 'Low', 2: 'Medium', 3: 'High' };
  return priorities[this.priority] || 'Low';
});

// Virtual for priority color
todoSchema.virtual('priorityColor').get(function() {
  const colors = { 1: '#4CAF50', 2: '#FF9800', 3: '#F44336' };
  return colors[this.priority] || '#4CAF50';
});

// Virtual for days until due
todoSchema.virtual('daysUntilDue').get(function() {
  if (!this.dueDate) return null;
  const now = new Date();
  const due = new Date(this.dueDate);
  const diffTime = due - now;
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  return diffDays;
});

// Virtual for overdue status
todoSchema.virtual('isOverdue').get(function() {
  if (!this.dueDate || this.isCompleted) return false;
  return new Date() > this.dueDate;
});

// Indexes for better query performance
todoSchema.index({ user: 1, createdAt: -1 });
todoSchema.index({ user: 1, isCompleted: 1 });
todoSchema.index({ user: 1, priority: -1 });
todoSchema.index({ user: 1, dueDate: 1 });
todoSchema.index({ user: 1, category: 1 });
todoSchema.index({ 'sharedWith.user': 1 });

// Pre-save middleware to ensure user exists
todoSchema.pre('save', async function(next) {
  if (this.isNew) {
    try {
      const User = mongoose.model('User');
      const userExists = await User.findById(this.user);
      if (!userExists) {
        throw new Error('User not found');
      }
    } catch (error) {
      return next(error);
    }
  }
  next();
});

// Static method to find todos by user
todoSchema.statics.findByUser = function(userId, options = {}) {
  const query = { user: userId };
  
  if (options.isCompleted !== undefined) {
    query.isCompleted = options.isCompleted;
  }
  
  if (options.priority) {
    query.priority = options.priority;
  }
  
  if (options.category) {
    query.category = options.category;
  }
  
  if (options.search) {
    query.$or = [
      { title: { $regex: options.search, $options: 'i' } },
      { description: { $regex: options.search, $options: 'i' } }
    ];
  }
  
  return this.find(query).sort({ priority: -1, createdAt: -1 });
};

// Static method to get user statistics
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
              { $and: [{ $ne: ['$dueDate', null] }, { $gt: [new Date(), '$dueDate'] }, { $eq: ['$isCompleted', false] }] },
              1,
              0
            ]
          }
        }
      }
    }
  ]);
  
  const result = stats[0] || { total: 0, completed: 0, pending: 0, highPriority: 0, overdue: 0 };
  result.completionPercentage = result.total > 0 ? (result.completed / result.total) * 100 : 0;
  
  return result;
};

const Todo = mongoose.model('Todo', todoSchema);

module.exports = Todo;

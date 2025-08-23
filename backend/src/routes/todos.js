const express = require('express');
const { body, validationResult, query } = require('express-validator');
const Todo = require('../models/Todo');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Apply authentication to all todo routes
router.use(auth);

// @route   GET /api/todos
// @desc    Get all todos for authenticated user
// @access  Private
router.get('/', [
  query('isCompleted').optional().isBoolean().withMessage('isCompleted must be a boolean'),
  query('priority').optional().isInt({ min: 1, max: 3 }).withMessage('Priority must be 1, 2, or 3'),
  query('category').optional().trim().isLength({ max: 50 }).withMessage('Category too long'),
  query('search').optional().trim().isLength({ max: 100 }).withMessage('Search query too long'),
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { isCompleted, priority, category, search, page = 1, limit = 20 } = req.query;
    
    // Build query options
    const options = {};
    if (isCompleted !== undefined) options.isCompleted = isCompleted === 'true';
    if (priority) options.priority = parseInt(priority);
    if (category) options.category = category;
    if (search) options.search = search;

    // Get todos with pagination
    const skip = (page - 1) * limit;
    const todos = await Todo.findByUser(req.user._id, options)
      .skip(skip)
      .limit(parseInt(limit))
      .populate('sharedWith.user', 'name email');

    // Get total count for pagination
    const totalTodos = await Todo.countDocuments({ user: req.user._id });

    // Get user statistics
    const stats = await Todo.getUserStats(req.user._id);

    res.json({
      success: true,
      data: {
        todos,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: totalTodos,
          pages: Math.ceil(totalTodos / limit)
        },
        stats
      }
    });
  } catch (error) {
    console.error('Get todos error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching todos'
    });
  }
});

// @route   GET /api/todos/:id
// @desc    Get single todo by ID
// @access  Private
router.get('/:id', async (req, res) => {
  try {
    const todo = await Todo.findOne({
      _id: req.params.id,
      $or: [
        { user: req.user._id },
        { 'sharedWith.user': req.user._id }
      ]
    }).populate('sharedWith.user', 'name email');

    if (!todo) {
      return res.status(404).json({
        success: false,
        message: 'Todo not found'
      });
    }

    res.json({
      success: true,
      data: { todo }
    });
  } catch (error) {
    console.error('Get todo error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching todo'
    });
  }
});

// @route   POST /api/todos
// @desc    Create a new todo
// @access  Private
router.post('/', [
  body('title')
    .trim()
    .isLength({ min: 1, max: 200 })
    .withMessage('Title must be between 1 and 200 characters'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 1000 })
    .withMessage('Description cannot exceed 1000 characters'),
  body('priority')
    .optional()
    .isInt({ min: 1, max: 3 })
    .withMessage('Priority must be 1, 2, or 3'),
  body('dueDate')
    .optional()
    .custom((value) => {
      if (value === null || value === undefined || value === '') {
        return true; // Allow null/undefined/empty values
      }
      // If a value is provided, validate it's a valid ISO date
      const date = new Date(value);
      return !isNaN(date.getTime());
    })
    .withMessage('Due date must be a valid ISO date or null'),
  body('category')
    .optional()
    .trim()
    .isLength({ max: 50 })
    .withMessage('Category cannot exceed 50 characters'),
  body('tags')
    .optional()
    .isArray({ max: 10 })
    .withMessage('Tags must be an array with maximum 10 items'),
  body('tags.*')
    .optional()
    .trim()
    .isLength({ min: 1, max: 20 })
    .withMessage('Each tag must be between 1 and 20 characters')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { title, description, priority, dueDate, category, tags } = req.body;

    const todo = new Todo({
      user: req.user._id,
      title,
      description: description || '',
      priority: priority || 1,
      dueDate: dueDate || null,
      category: category || 'General',
      tags: tags || []
    });

    await todo.save();

    res.status(201).json({
      success: true,
      message: 'Todo created successfully',
      data: { todo }
    });
  } catch (error) {
    console.error('Create todo error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while creating todo'
    });
  }
});

// @route   PUT /api/todos/:id
// @desc    Update a todo
// @access  Private
router.put('/:id', [
  body('title')
    .optional()
    .trim()
    .isLength({ min: 1, max: 200 })
    .withMessage('Title must be between 1 and 200 characters'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 1000 })
    .withMessage('Description cannot exceed 1000 characters'),
  body('priority')
    .optional()
    .isInt({ min: 1, max: 3 })
    .withMessage('Priority must be 1, 2, or 3'),
  body('dueDate')
    .optional()
    .custom((value) => {
      if (value === null || value === undefined || value === '') {
        return true; // Allow null/undefined/empty values
      }
      // If a value is provided, validate it's a valid ISO date
      const date = new Date(value);
      return !isNaN(date.getTime());
    })
    .withMessage('Due date must be a valid ISO date or null'),
  body('category')
    .optional()
    .trim()
    .isLength({ max: 50 })
    .withMessage('Category cannot exceed 50 characters'),
  body('tags')
    .optional()
    .isArray({ max: 10 })
    .withMessage('Tags must be an array with maximum 10 items')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const todo = await Todo.findOne({
      _id: req.params.id,
      user: req.user._id
    });

    if (!todo) {
      return res.status(404).json({
        success: false,
        message: 'Todo not found'
      });
    }

    // Update fields
    const updateFields = ['title', 'description', 'priority', 'dueDate', 'category', 'tags'];
    updateFields.forEach(field => {
      if (req.body[field] !== undefined) {
        todo[field] = req.body[field];
      }
    });

    await todo.save();

    res.json({
      success: true,
      message: 'Todo updated successfully',
      data: { todo }
    });
  } catch (error) {
    console.error('Update todo error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating todo'
    });
  }
});

// @route   PATCH /api/todos/:id/toggle
// @desc    Toggle todo completion status
// @access  Private
router.patch('/:id/toggle', async (req, res) => {
  try {
    const todo = await Todo.findOne({
      _id: req.params.id,
      user: req.user._id
    });

    if (!todo) {
      return res.status(404).json({
        success: false,
        message: 'Todo not found'
      });
    }

    todo.isCompleted = !todo.isCompleted;
    if (todo.isCompleted) {
      todo.completedAt = new Date();
    } else {
      todo.completedAt = null;
    }

    await todo.save();

    res.json({
      success: true,
      message: `Todo marked as ${todo.isCompleted ? 'completed' : 'pending'}`,
      data: { todo }
    });
  } catch (error) {
    console.error('Toggle todo error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while toggling todo'
    });
  }
});

// @route   DELETE /api/todos/:id
// @desc    Delete a todo
// @access  Private
router.delete('/:id', async (req, res) => {
  try {
    const todo = await Todo.findOneAndDelete({
      _id: req.params.id,
      user: req.user._id
    });

    if (!todo) {
      return res.status(404).json({
        success: false,
        message: 'Todo not found'
      });
    }

    res.json({
      success: true,
      message: 'Todo deleted successfully'
    });
  } catch (error) {
    console.error('Delete todo error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting todo'
    });
  }
});

// @route   DELETE /api/todos/clear-completed
// @desc    Clear all completed todos for user
// @access  Private
router.delete('/clear-completed', async (req, res) => {
  try {
    const result = await Todo.deleteMany({
      user: req.user._id,
      isCompleted: true
    });

    res.json({
      success: true,
      message: `Cleared ${result.deletedCount} completed todos`
    });
  } catch (error) {
    console.error('Clear completed todos error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while clearing completed todos'
    });
  }
});

// @route   GET /api/todos/stats/summary
// @desc    Get todo statistics summary
// @access  Private
router.get('/stats/summary', async (req, res) => {
  try {
    const stats = await Todo.getUserStats(req.user._id);

    res.json({
      success: true,
      data: { stats }
    });
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching statistics'
    });
  }
});

module.exports = router;

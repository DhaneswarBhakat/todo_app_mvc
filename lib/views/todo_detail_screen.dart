import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/api_service.dart';
import '../utils/todo_widgets.dart';

class TodoDetailScreen extends StatefulWidget {
  final Todo todo;

  const TodoDetailScreen({super.key, required this.todo});

  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  late Todo _todo;
  bool _isEditing = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late int _selectedPriority;
  late String _selectedCategory;

  final List<String> _categories = [
    'General',
    'Work',
    'Personal',
    'Shopping',
    'Health',
    'Education',
    'Travel',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _todo = widget.todo;
    _titleController = TextEditingController(text: _todo.title);
    _descriptionController = TextEditingController(text: _todo.description);
    _selectedPriority = _todo.priority;
    _selectedCategory = _todo.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        print('🔄 Updating todo via API: ${_todo.id}');
        print('📝 New title: ${_titleController.text}');
        print('📄 New description: ${_descriptionController.text}');
        print('⭐ New priority: $_selectedPriority');
        print('🏷️ New category: $_selectedCategory');

        final updatedTodo = await ApiService.updateTodo(
          id: _todo.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          category: _selectedCategory,
        );

        setState(() {
          _todo = updatedTodo;
          _isEditing = false;
        });

        print('✅ Todo updated successfully via API');
        print('📊 Updated todo data: ${updatedTodo.toMap()}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Todo updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

      } catch (error) {
        print('❌ Error updating todo via API: $error');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Failed to update todo: ${error.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _toggleCompletion() async {
    try {
      print('🔄 Toggling todo completion: ${_todo.id}');
      
      final updatedTodo = await ApiService.toggleTodoCompletion(_todo.id);
      
      setState(() {
        _todo = updatedTodo;
      });

      print('✅ Todo completion toggled successfully');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _todo.isCompleted 
                ? '✅ Todo marked as completed!' 
                : '⏳ Todo marked as pending!'
            ),
            backgroundColor: _todo.isCompleted ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }

    } catch (error) {
      print('❌ Error toggling todo completion: $error');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to update todo: ${error.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _deleteTodo() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "${_todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        print('🗑️ Deleting todo: ${_todo.id}');
        
        await ApiService.deleteTodo(_todo.id);
        
        print('✅ Todo deleted successfully');
        
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate deletion
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🗑️ Todo "${_todo.title}" deleted'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        
      } catch (error) {
        print('❌ Error deleting todo: $error');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Failed to delete todo: ${error.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Todo' : 'Todo Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTodo,
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isEditing ? _buildEditForm() : _buildDetailView(),
      ),
    );
  }

  Widget _buildDetailView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Priority Indicator
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: Color(_todo.priorityColor),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          _todo.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            decoration: _todo.isCompleted ? TextDecoration.lineThrough : null,
            color: _todo.isCompleted ? Colors.grey : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Description
        if (_todo.description.isNotEmpty) ...[
          Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _todo.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              decoration: _todo.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Details
        _buildDetailRow('Status', _todo.isCompleted ? 'Completed' : 'Pending'),
        _buildDetailRow('Priority', _todo.priorityString),
        _buildDetailRow('Category', _todo.category),
        if (_todo.dueDate != null) _buildDetailRow('Due Date', _todo.dueDate!.toString().split(' ')[0]),
        if (_todo.tags.isNotEmpty) _buildDetailRow('Tags', _todo.tags.join(', ')),
        _buildDetailRow('Created', _todo.createdAt.toString().split(' ')[0]),
        _buildDetailRow('Updated', _todo.updatedAt.toString().split(' ')[0]),

        const Spacer(),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _toggleCompletion,
                icon: Icon(_todo.isCompleted ? Icons.pending : Icons.check_circle),
                label: Text(_todo.isCompleted ? 'Mark Pending' : 'Mark Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _todo.isCompleted ? Colors.orange : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title Field
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title *',
              hintText: 'Enter todo title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a title';
              }
              if (value.trim().length > 200) {
                return 'Title cannot exceed 200 characters';
              }
              return null;
            },
            maxLength: 200,
          ),
          const SizedBox(height: 16),

          // Description Field
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Enter todo description (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            maxLength: 1000,
          ),
          const SizedBox(height: 16),

          // Priority Selector
          Row(
            children: [
              const Text('Priority: ', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: PrioritySelector(
                  selectedPriority: _selectedPriority,
                  onPriorityChanged: (priority) {
                    setState(() {
                      _selectedPriority = priority;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Dropdown
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () {
                    setState(() {
                      _isEditing = false;
                      _titleController.text = _todo.title;
                      _descriptionController.text = _todo.description;
                      _selectedPriority = _todo.priority;
                      _selectedCategory = _todo.category;
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Saving...'),
                          ],
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
} 
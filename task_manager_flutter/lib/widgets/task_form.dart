import 'package:flutter/material.dart';

import 'due_date_field.dart';

class TaskForm extends StatefulWidget {
  final Future<void> Function(
    String title,
    String? description,
    int priority,
    DateTime? dueDate,
  ) onSubmit;

  const TaskForm({
    super.key,
    required this.onSubmit,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _priority = 1;
  DateTime? _dueDate;

  bool get _isValid => _titleController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_isValid) {
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    await widget.onSubmit(
      title,
      description.isEmpty ? null : description,
      _priority,
      _dueDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add New Task',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Priority',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Low'),
                selected: _priority == 0,
                selectedColor: Colors.green.withValues(alpha: 0.2),
                onSelected: (_) => setState(() => _priority = 0),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Medium'),
                selected: _priority == 1,
                selectedColor: Colors.orange.withValues(alpha: 0.2),
                onSelected: (_) => setState(() => _priority = 1),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('High'),
                selected: _priority == 2,
                selectedColor: Colors.red.withValues(alpha: 0.2),
                onSelected: (_) => setState(() => _priority = 2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Due Date',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DueDateField(
            selectedDate: _dueDate,
            onChanged: (date) => setState(() => _dueDate = date),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E60F7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isValid ? _handleSubmit : null,
              child: const Text(
                'Save Task',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tasks.dart';
import '../task_list/task_list_view_model.dart';
import 'task_details_view_model.dart';

class TaskDetailsMobileView extends StatefulWidget {
  final Tasks task;

  const TaskDetailsMobileView({super.key, required this.task});

  @override
  State<TaskDetailsMobileView> createState() => _TaskDetailsMobileViewState();
}

class _TaskDetailsMobileViewState extends State<TaskDetailsMobileView> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late int _priority;
  late bool _isCompleted;
  late String _category;
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(
      text: widget.task.description ?? '',
    );
    _priority = widget.task.priority;
    _isCompleted = widget.task.isCompleted;
    _category = widget.task.category ?? 'Personal';
    _dueDate = widget.task.dueDate ?? widget.task.createdAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _showCenterErrorSnackBar(BuildContext context, String message) {
    final mediaQuery = MediaQuery.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        margin: EdgeInsets.only(
          bottom: mediaQuery.size.height * 0.45,
          left: 24,
          right: 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailsViewModel = context.watch<TaskDetailsViewModel>();
    final taskListViewModel = context.watch<TaskListViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Task Details',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Completed Status',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Switch(
                    value: _isCompleted,
                    activeThumbColor: const Color(0xFF1E60F7),
                    onChanged: (value) => setState(() => _isCompleted = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Task Title',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: taskListViewModel.categories.map((cat) {
                final isSelected = _category == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: const Color(0xFF1E60F7).withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color:
                        isSelected ? const Color(0xFF1E60F7) : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) => setState(() => _category = cat),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Priority Level',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPriorityChip(
                  0,
                  'Low',
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildPriorityChip(1, 'Medium', Colors.orange),
                const SizedBox(width: 8),
                _buildPriorityChip(2, 'High', Colors.red),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Due Date & Time',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Color(0xFF1E60F7),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_getMonthName(_dueDate.month).substring(0, 3)} ${_dueDate.day}, ${_dueDate.year} at ${_formatTime(_dueDate)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_dueDate),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _dueDate = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    child: const Text(
                      'Select',
                      style: TextStyle(
                        color: Color(0xFF1E60F7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E60F7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: detailsViewModel.state == DetailsViewState.loading
                    ? null
                    : () async {
                        final title = _titleController.text.trim();
                        if (title.isEmpty) {
                          _showCenterErrorSnackBar(
                            context,
                            'Task Title cannot be empty or blank.',
                          );
                          return;
                        }

                        final updatedTask = widget.task.copyWith(
                          title: title,
                          description: _descController.text.trim(),
                          priority: _priority,
                          isCompleted: _isCompleted,
                          category: _category,
                          dueDate: _dueDate,
                        );

                        final success = await detailsViewModel.updateTask(
                          updatedTask,
                        );

                        if (mounted) {
                          if (success) {
                            context.read<TaskListViewModel>().fetchTasks();
                            Navigator.pop(context);
                          } else {
                            final error = detailsViewModel.errorMessage;
                            if (error != null) {
                              _showCenterErrorSnackBar(context, error);
                            }
                          }
                        }
                      },
                child: detailsViewModel.state == DetailsViewState.loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(int value, String label, Color color) {
    final isSelected = _priority == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _priority = value),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

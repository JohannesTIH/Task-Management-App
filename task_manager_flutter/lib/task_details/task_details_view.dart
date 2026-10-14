import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tasks.dart';
import '../repositories/task_repository.dart';
import 'task_details_mobile_view.dart';
import 'task_details_view_model.dart';

class TaskDetailsView extends StatelessWidget {
  final Tasks task;

  const TaskDetailsView({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskDetailsViewModel(context.read<TaskRepository>()),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return TaskDetailsMobileView(task: task);
          }

          return TaskDetailsMobileView(task: task);
        },
      ),
    );
  }
}

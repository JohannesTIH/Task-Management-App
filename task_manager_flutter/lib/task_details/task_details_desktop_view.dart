import 'package:flutter/material.dart';

import '../models/tasks.dart';
import 'task_details_mobile_view.dart';

class TaskDetailsDesktopView extends StatelessWidget {
  final Tasks task;

  const TaskDetailsDesktopView({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 650,
                  child: TaskDetailsMobileView(task: task),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

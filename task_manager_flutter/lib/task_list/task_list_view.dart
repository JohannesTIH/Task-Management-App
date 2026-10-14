import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'task_list_desktop_view.dart';
import 'task_list_mobile_view.dart';
import 'task_list_view_model.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({super.key});

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskListViewModel>().fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return const TaskListMobileView();
        }

        return const TaskListDesktopView();
      },
    );
  }
}

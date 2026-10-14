import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../models/tasks.dart';
import '../task_details/task_details_view.dart';
import '../task_list/task_list_view_model.dart';

class TaskListMobileView extends StatefulWidget {
  const TaskListMobileView({super.key, this.isDesktop = false});

  final bool isDesktop;

  @override
  State<TaskListMobileView> createState() => _TaskListMobileViewState();
}

class _TaskListMobileViewState extends State<TaskListMobileView> {
  // Navigation Bar selected index: 0 = Home, 1 = Calendar, 2 = Overdue, 3 = Priority
  int _selectedNavIndex = 1; // Default selected: Task List / Calendar View (1)

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TaskListViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: widget.isDesktop
          ? null
          : _buildDrawer(context, viewModel),
      appBar: _selectedNavIndex == 0
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: widget.isDesktop
                  ? null
                  : Builder(
                      builder: (drawerContext) => IconButton(
                        icon: const Icon(Icons.menu_rounded, color: Colors.black87),
                        onPressed: () => Scaffold.of(drawerContext).openDrawer(),
                      ),
                    ),
              title: const Text(
                'Tasks',
                style: TextStyle(
                  color: Color.fromARGB(221, 20, 20, 20),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
            ),
      body: _buildPageBody(context, viewModel),
      bottomNavigationBar: _buildBottomNavigationBar(viewModel),
    );
  }

  Widget _buildPageBody(BuildContext context, TaskListViewModel viewModel) {
    switch (_selectedNavIndex) {
      case 0: // Home Dashboard Page
        return _buildHomeDashboardView(context, viewModel);

      case 1: // Task List Page (Shows Month Header & Date Strip)
        return Column(
          children: [
            _buildMonthHeader(viewModel.selectedDate),
            const SizedBox(height: 4),
            _buildDateStrip(context, viewModel),
            const SizedBox(height: 12),
            _buildSectionHeader(viewModel),
            const SizedBox(height: 8),
            Expanded(child: _buildTaskContent(context, viewModel)),
          ],
        );

      case 2: // Overdue Tasks Page
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverdueHeader(viewModel),
            const SizedBox(height: 8),
            Expanded(child: _buildTaskContent(context, viewModel)),
          ],
        );

      case 3: // Priority Filter Page
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriorityHeader(viewModel),
            const SizedBox(height: 8),
            Expanded(child: _buildTaskContent(context, viewModel)),
          ],
        );

      default:
        return _buildHomeDashboardView(context, viewModel);
    }
  }

  Widget _buildOverdueHeader(TaskListViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(
                Icons.access_time_filled_rounded,
                color: Colors.redAccent,
                size: 26,
              ),
              SizedBox(width: 10),
              Text(
                'Overdue Tasks',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Tasks past their due date that require attention',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityHeader(TaskListViewModel viewModel) {
    String priorityLabel = 'All Priorities';
    Color labelColor = const Color(0xFF1E60F7);

    if (viewModel.selectedPriorityFilter == 0) {
      priorityLabel = 'Low Priority Tasks';
      labelColor = Colors.green;
    } else if (viewModel.selectedPriorityFilter == 1) {
      priorityLabel = 'Medium Priority Tasks';
      labelColor = Colors.orange;
    } else if (viewModel.selectedPriorityFilter == 2) {
      priorityLabel = 'High Priority Tasks';
      labelColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flag_rounded, color: labelColor, size: 26),
                  const SizedBox(width: 10),
                  Text(
                    priorityLabel,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Tasks filtered by priority level',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () => _showPriorityFilterSheet(context, viewModel),
            icon: const Icon(Icons.filter_list_rounded, size: 20),
            label: const Text('Filter'),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeDashboardView(
    BuildContext context,
    TaskListViewModel viewModel,
  ) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    final formattedDate = _formatFullDate(now);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isDesktop)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Builder(
                  builder: (drawerContext) => IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    icon: const Icon(Icons.menu_rounded, color: Colors.black87, size: 28),
                    onPressed: () => Scaffold.of(drawerContext).openDrawer(),
                  ),
                ),
              ),

            // Greeting & Date Header
            Text(
              greeting,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Big Headline
            const Text(
              "Let's Do Something",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.1,
              ),
            ),
            const Text(
              "Great Today!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black38,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 24),

            // Category cards and the add-task card
            _buildCategoryCardsGrid(context, viewModel),
            const SizedBox(height: 24),

            // Today's Task Section Header
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                "Today's Task",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // Today's Tasks List
            _buildTodayTasksList(context, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCardsGrid(
    BuildContext context,
    TaskListViewModel viewModel,
  ) {
    final categories = viewModel.categories;

    final colors = [
      const Color(0xFFE2F1E1), // Pastel Green
      const Color(0xFFE0F2F1), // Pastel Teal
      const Color(0xFFFFF4D3), // Pastel Yellow
      const Color(0xFFE8EAF6), // Pastel Indigo
      const Color(0xFFFCE4EC), // Pastel Pink
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        if (index == categories.length) {
          // '+' Add Task Card
          return GestureDetector(
            onTap: () => _showAddTaskBottomSheet(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.shade400,
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Icon(Icons.add, size: 32, color: Colors.black54),
              ),
            ),
          );
        }

        final cat = categories[index];
        final cardColor = colors[index % colors.length];
        final taskCount = viewModel.getCategoryTaskCount(cat);

        return GestureDetector(
          onTap: () {
            viewModel.selectCategory(cat);
            setState(() {
              _selectedNavIndex = 1; // Switch to Calendar View
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cat,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Icon(
                      _getCategoryIcon(cat),
                      size: 22,
                      color: Colors.black87,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$taskCount Tasks',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: taskCount > 0 ? 0.6 : 0.0,
                        backgroundColor: Colors.black.withValues(alpha: 0.08),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF1E60F7),
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodayTasksList(
    BuildContext context,
    TaskListViewModel viewModel,
  ) {
    final todayTasks = viewModel.getTasksForDate(DateTime.now());
    if (todayTasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No tasks for today',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
      );
    }

    return Column(
      children: todayTasks.map((task) {
        return _buildTaskCard(context, viewModel, task);
      }).toList(),
    );
  }

  Widget _buildDrawer(BuildContext context, TaskListViewModel viewModel) {
    final isEyeComfortMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final headerBgColor = isEyeComfortMode
        ? const Color(0xFFD2A679)
        : const Color(0xFF1E60F7);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header with To-Do List Icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: headerBgColor),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.task_alt_rounded, // Single tick icon
                      color: Color(0xFF1E60F7),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Task Manager App',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Padding(
                          padding: EdgeInsets.only(left: 32),
                          child: Text(
                            'by',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'SJ Motsemme',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Categories Section Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  // All Tasks Category
                  ListTile(
                    leading: const Icon(
                      Icons.grid_view_rounded,
                      color: Color(0xFF1E60F7),
                    ),
                    title: const Text('All Tasks'),
                    trailing: _buildBadge(viewModel.allTasksCount),
                    selected: viewModel.selectedCategoryFilter == null,
                    selectedTileColor: const Color(0xFF1E60F7)
                        .withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      viewModel.selectCategory(null);
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(),

                  // Categories List
                  ...viewModel.categories.map((cat) {
                    final isSelected = viewModel.selectedCategoryFilter == cat;
                    final count = viewModel.getCategoryTaskCount(cat);

                    return ListTile(
                      leading: Icon(
                        _getCategoryIcon(cat),
                        color: isSelected
                            ? const Color(0xFF1E60F7)
                            : Colors.grey.shade700,
                      ),
                      title: Text(cat),
                      trailing: _buildBadge(count),
                      selected: isSelected,
                      selectedTileColor: const Color(0xFF1E60F7)
                          .withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        viewModel.selectCategory(cat);
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            ),

            const Divider(height: 1),

            // Eye Comfort Shield Toggle Switch
            Consumer<ThemeNotifier>(
              builder: (context, themeNotifier, child) {
                return SwitchListTile(
                  secondary: Icon(
                    themeNotifier.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.dark_mode_outlined,
                    color: const Color(0xFF1E60F7),
                  ),
                  title: const Text(
                    'Eye Comfort Shield',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  value: themeNotifier.isDarkMode,
                  onChanged: (isDark) => themeNotifier.toggleTheme(isDark),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1E60F7).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF1E60F7).withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Color(0xFF1E60F7),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Icons.work_outline_rounded;
      case 'personal':
        return Icons.person_outline_rounded;
      case 'study':
        return Icons.school_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  Widget _buildMonthHeader(DateTime selectedDate) {
    final prevMonth = DateTime(selectedDate.year, selectedDate.month - 1);
    final currMonth = selectedDate;
    final nextMonth = DateTime(selectedDate.year, selectedDate.month + 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${prevMonth.year} ${_getMonthName(prevMonth.month)}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${currMonth.year} ${_getMonthName(currMonth.month)}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${nextMonth.year} ${_getMonthName(nextMonth.month)}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStrip(BuildContext context, TaskListViewModel viewModel) {
    final today = DateTime.now();

    final days = List.generate(
      7,
      (index) => today.add(Duration(days: index - 2)),
    );

    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: widget.isDesktop
          ? Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: days
                    .map((date) => _buildDateCard(date, viewModel))
                    .toList(),
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) =>
                  _buildDateCard(days[index], viewModel),
            ),
    );
  }

  Widget _buildDateCard(DateTime date, TaskListViewModel viewModel) {
    final isSelected =
        date.day == viewModel.selectedDate.day &&
        date.month == viewModel.selectedDate.month;

    return GestureDetector(
      onTap: () => viewModel.selectDate(date),
      child: Container(
        width: 55,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E60F7) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E60F7).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getDayName(date.weekday),
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(TaskListViewModel viewModel) {
    String title = 'Today\'s Task';
    if (viewModel.selectedCategoryFilter != null) {
      title = '${viewModel.selectedCategoryFilter} Tasks';
    } else if (viewModel.showOverdueOnly) {
      title = 'Overdue Tasks';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskContent(BuildContext context, TaskListViewModel viewModel) {
    if (viewModel.state == ViewState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.state == ViewState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              viewModel.errorMessage ?? 'Error occurred',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: viewModel.fetchTasks,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.tasks.isEmpty) {
      String emptyMessage = 'No tasks for this day';
      if (viewModel.selectedCategoryFilter != null) {
        emptyMessage = 'No tasks in "${viewModel.selectedCategoryFilter}"';
      } else if (viewModel.showOverdueOnly) {
        emptyMessage = 'No overdue tasks!';
      }

      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: viewModel.tasks.length,
      itemBuilder: (context, index) {
        final task = viewModel.tasks[index];
        final isLast = index == viewModel.tasks.length - 1;
        return _buildTimelineItem(context, viewModel, task, isLast);
      },
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    TaskListViewModel viewModel,
    Tasks task,
    bool isLast,
  ) {
    final taskDate = task.dueDate ?? task.createdAt;
    final formattedTime = _formatTime(taskDate);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Time Column + Vertical Timeline Line
          SizedBox(
            width: 70,
            child: Column(
              children: [
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.unfold_more_rounded,
                        size: 14,
                        color: Color(0xFF1E60F7),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 1.5,
                            color: const Color(0xFF1E60F7)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Task Card
          Expanded(child: _buildTaskCard(context, viewModel, task)),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    TaskListViewModel viewModel,
    Tasks task,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.isCompleted,
            activeColor: const Color(0xFF1E60F7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (_) => viewModel.toggleTaskStatus(task),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _navigateToTaskDetails(context, task),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompleted ? Colors.grey : Colors.black87,
                    ),
                  ),
                  if (task.description != null &&
                      task.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildPriorityBadge(task.priority),
                      if (task.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E60F7)
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: const Color(0xFF1E60F7)
                                  .withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            task.category!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E60F7),
                            ),
                          ),
                        ),
                      if (task.isOffline || task.isPendingUpdate)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.amber.shade400,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cloud_off_rounded,
                                size: 12,
                                color: Colors.amber.shade800,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  task.isOffline ? 'Offline' : 'Edited',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Color(0xFF1E60F7),
              size: 22,
            ),
            tooltip: 'Edit Task',
            onPressed: () => _navigateToTaskDetails(context, task),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
              size: 22,
            ),
            tooltip: 'Delete Task',
            onPressed: () => _confirmDeleteTask(context, viewModel, task),
          ),
        ],
      ),
    );
  }

  void _showCenterErrorSnackBar(BuildContext context, String message) {
    final overlay = Overlay.maybeOf(context);
    if (overlay != null) {
      late OverlayEntry overlayEntry;
      overlayEntry = OverlayEntry(
        builder: (entryContext) => Positioned(
          top: MediaQuery.of(context).size.height * 0.35,
          left: 24,
          right: 24,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry);

      Future.delayed(const Duration(seconds: 4), () {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
      });
      return;
    }

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _confirmDeleteTask(
    BuildContext context,
    TaskListViewModel viewModel,
    Tasks task,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete "${task.title}" permanently?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await viewModel.deleteTask(task.id);
              if (!success && context.mounted) {
                final error = viewModel.errorMessage;
                if (error != null) {
                  _showCenterErrorSnackBar(context, error);
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToTaskDetails(BuildContext context, Tasks task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailsView(task: task)),
    );
  }

  Widget _buildPriorityBadge(int priority) {
    String label = 'Low';
    Color color = Colors.green;

    if (priority == 1) {
      label = 'Medium';
      color = Colors.orange;
    } else if (priority == 2) {
      label = 'High';
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border(
          left: BorderSide(color: color, width: 3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(TaskListViewModel viewModel) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: _selectedNavIndex == 1
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            // Left Pill: Floating Navigation Bar Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNavItem(
                    0,
                    Icons.home_outlined,
                    Icons.home_rounded,
                    viewModel,
                  ),
                  const SizedBox(width: 4),
                  _buildNavItem(
                    1,
                    Icons.checklist_outlined,
                    Icons.checklist_rounded,
                    viewModel,
                  ),
                  const SizedBox(width: 4),
                  _buildNavItem(
                    2,
                    Icons.access_time_outlined,
                    Icons.access_time_filled_rounded,
                    viewModel,
                  ),
                  const SizedBox(width: 4),
                  _buildNavItem(
                    3,
                    Icons.flag_outlined,
                    Icons.flag_rounded,
                    viewModel,
                  ),
                ],
              ),
            ),

            // Right Button: Floating '+' Add Task Button
            if (_selectedNavIndex == 1)
              GestureDetector(
                onTap: () => _showAddTaskBottomSheet(context),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.black87, size: 28),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData unselectedIcon,
    IconData selectedIcon,
    TaskListViewModel viewModel,
  ) {
    final isSelected = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
        if (index == 2) {
          viewModel.toggleOverdueFilter(true);
          viewModel.filterByPriority(null);
        } else if (index == 3) {
          viewModel.toggleOverdueFilter(false);
          _showPriorityFilterSheet(context, viewModel);
        } else {
          viewModel.toggleOverdueFilter(false);
          viewModel.filterByPriority(null);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E60F7) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? selectedIcon : unselectedIcon,
          color: isSelected ? Colors.white : Colors.black54,
          size: 22,
        ),
      ),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    int selectedPriority = 1;
    DateTime selectedDueDate = DateTime.now();

    final viewModel = context.read<TaskListViewModel>();
    String selectedCategory =
        viewModel.selectedCategoryFilter ?? viewModel.categories.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF7F9FC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
                top: 24,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Add New Task',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Task Title',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter task title...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...viewModel.categories.map((cat) {
                          final isCatSelected = selectedCategory == cat;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: isCatSelected,
                            selectedColor: const Color(0xFF1E60F7)
                                .withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              color: isCatSelected
                                  ? const Color(0xFF1E60F7)
                                  : Colors.black87,
                              fontWeight: isCatSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (_) =>
                                setModalState(() => selectedCategory = cat),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter task description (optional)...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Priority Level',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Low'),
                          selected: selectedPriority == 0,
                          selectedColor: Colors.green.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: selectedPriority == 0
                                ? Colors.green
                                : Colors.black87,
                            fontWeight: selectedPriority == 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (_) =>
                              setModalState(() => selectedPriority = 0),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Medium'),
                          selected: selectedPriority == 1,
                          selectedColor: Colors.orange.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: selectedPriority == 1
                                ? Colors.orange
                                : Colors.black87,
                            fontWeight: selectedPriority == 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (_) =>
                              setModalState(() => selectedPriority = 1),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('High'),
                          selected: selectedPriority == 2,
                          selectedColor: Colors.red.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: selectedPriority == 2
                                ? Colors.red
                                : Colors.black87,
                            fontWeight: selectedPriority == 2
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (_) =>
                              setModalState(() => selectedPriority = 2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Due Date & Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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
                                '${_getMonthName(selectedDueDate.month).substring(0, 3)} ${selectedDueDate.day}, ${selectedDueDate.year} at ${_formatTime(selectedDueDate)}',
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
                                initialDate: selectedDueDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                final pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                    selectedDueDate,
                                  ),
                                );
                                if (pickedTime != null) {
                                  setModalState(() {
                                    selectedDueDate = DateTime(
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
                    const SizedBox(height: 32),
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
                        onPressed: () async {
                          final title = titleController.text.trim();
                          if (title.isEmpty) {
                            _showCenterErrorSnackBar(
                              modalContext,
                              'Client-Side Error (400 Bad Request): Task Title cannot be empty or blank.',
                            );
                            return;
                          }

                          final success = await context
                              .read<TaskListViewModel>()
                              .addTask(
                                title,
                                descController.text.trim(),
                                selectedPriority,
                                selectedDueDate,
                                selectedCategory,
                              );
                          if (context.mounted) {
                            if (success) {
                              Navigator.pop(modalContext);
                            } else {
                              final error = context
                                  .read<TaskListViewModel>()
                                  .errorMessage;
                              if (error != null) {
                                _showCenterErrorSnackBar(modalContext, error);
                              }
                            }
                          }
                        },
                        child: const Text(
                          'Save Task',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _formatFullDate(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dayName = days[date.weekday - 1];
    final monthName = _getMonthName(date.month).substring(0, 3);
    return '$dayName, $monthName ${date.day}';
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
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

  void _showPriorityFilterSheet(
    BuildContext context,
    TaskListViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by Priority',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.clear_all, color: Colors.blue),
                title: const Text('All Priorities'),
                trailing: viewModel.selectedPriorityFilter == null
                    ? const Icon(Icons.check, color: Color(0xFF1E60F7))
                    : null,
                onTap: () {
                  viewModel.filterByPriority(null);
                  Navigator.pop(modalContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag, color: Colors.green),
                title: const Text('Low Priority'),
                trailing: viewModel.selectedPriorityFilter == 0
                    ? const Icon(Icons.check, color: Color(0xFF1E60F7))
                    : null,
                onTap: () {
                  viewModel.filterByPriority(0);
                  Navigator.pop(modalContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag, color: Colors.orange),
                title: const Text('Medium Priority'),
                trailing: viewModel.selectedPriorityFilter == 1
                    ? const Icon(Icons.check, color: Color(0xFF1E60F7))
                    : null,
                onTap: () {
                  viewModel.filterByPriority(1);
                  Navigator.pop(modalContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag, color: Colors.red),
                title: const Text('High Priority'),
                trailing: viewModel.selectedPriorityFilter == 2
                    ? const Icon(Icons.check, color: Color(0xFF1E60F7))
                    : null,
                onTap: () {
                  viewModel.filterByPriority(2);
                  Navigator.pop(modalContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../task_list/task_list_view_model.dart';
import 'task_list_mobile_view.dart';

class TaskListDesktopView extends StatefulWidget {
  const TaskListDesktopView({super.key});

  @override
  State<TaskListDesktopView> createState() => _TaskListDesktopViewState();
}

class _TaskListDesktopViewState extends State<TaskListDesktopView> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TaskListViewModel>();
    final isEyeComfortMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final headerBgColor =
        isEyeComfortMode ? const Color(0xFFD2A679) : const Color(0xFF1E60F7);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          // Fixed Desktop Side Navigation Panel
          SizedBox(
            width: 300,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header Card
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
                              Icons.task_alt_rounded,
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
                                Text(
                                  'by SJ Motsemme',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Categories Header
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.grid_view_rounded,
                              color: Color(0xFF1E60F7),
                            ),
                            title: const Text('All Tasks'),
                            trailing: _buildBadge(viewModel.allTasksCount),
                            selected: viewModel.selectedCategoryFilter == null,
                            selectedTileColor:
                                const Color(0xFF1E60F7).withValues(alpha: 0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onTap: () => viewModel.selectCategory(null),
                          ),
                          const Divider(),
                          ...viewModel.categories.map((cat) {
                            final isSelected =
                                viewModel.selectedCategoryFilter == cat;
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
                              selectedTileColor:
                                  const Color(0xFF1E60F7).withValues(alpha: 0.08),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onTap: () => viewModel.selectCategory(cat),
                            );
                          }),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

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
            ),
          ),

          // Main Screen Area (isDesktop: true hides top-left hamburger menu)
          Expanded(
            child: const TaskListMobileView(isDesktop: true),
          ),
        ],
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
}

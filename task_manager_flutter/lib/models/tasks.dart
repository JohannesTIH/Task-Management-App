class Tasks {
  final int id;
  final String title;
  final String? description;
  final bool isCompleted;
  final int priority; // With Low = 0, Medium = 1 and High = 2
  final String? category; // e.g. Work, Personal, Study, or Custom
  final DateTime? dueDate;
  final DateTime createdAt;
  final bool isOffline; // Indicates task was created offline pending Web API sync
  final bool isPendingUpdate; // Indicates task was updated offline pending Web API sync
  final bool isPendingDelete; // Indicates task was deleted offline pending Web API sync

  Tasks({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.priority = 1,
    this.category = 'Personal',
    this.dueDate,
    this.isOffline = false,
    this.isPendingUpdate = false,
    this.isPendingDelete = false,
  });

  factory Tasks.fromJson(Map<String, dynamic> returned_json) {
    final cat = returned_json['category'] ?? returned_json['Category'];
    return Tasks(
      id: (returned_json['id'] ?? returned_json['Id']) as int,
      title: (returned_json['title'] ?? returned_json['Title']) as String,
      description:
          (returned_json['description'] ?? returned_json['Description'])
              as String?,
      isCompleted:
          (returned_json['isCompleted'] ?? returned_json['IsCompleted'])
                  as bool? ??
              false,
      priority: (returned_json['priority'] ?? returned_json['Priority'])
              as int? ??
          1,
      category: (cat != null && cat.toString().isNotEmpty)
          ? cat.toString()
          : 'Personal',
      dueDate: returned_json['dueDate'] != null
          ? DateTime.parse(returned_json['dueDate'])
          : (returned_json['DueDate'] != null
              ? DateTime.parse(returned_json['DueDate'])
              : null),
      createdAt: DateTime.parse(
        returned_json['createdAt'] ?? returned_json['CreatedAt'],
      ),
      isOffline: (returned_json['isOffline'] ?? returned_json['IsOffline'])
              as bool? ??
          false,
      isPendingUpdate: (returned_json['isPendingUpdate'] ??
              returned_json['IsPendingUpdate']) as bool? ??
          false,
      isPendingDelete: (returned_json['isPendingDelete'] ??
              returned_json['IsPendingDelete']) as bool? ??
          false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority,
      'category': category ?? 'Personal',
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isOffline': isOffline,
      'isPendingUpdate': isPendingUpdate,
      'isPendingDelete': isPendingDelete,
    };
  }

  factory Tasks.fromMap(Map<String, dynamic> sqlite_row) {
    final cat = sqlite_row['category'];
    return Tasks(
      id: sqlite_row['id'] as int,
      title: sqlite_row['title'] as String,
      description: sqlite_row['description'] as String?,
      isCompleted: (sqlite_row['isCompleted'] as int) == 1,
      priority: sqlite_row['priority'] as int,
      category: (cat != null && cat.toString().isNotEmpty)
          ? cat.toString()
          : 'Personal',
      dueDate: sqlite_row['dueDate'] != null
          ? DateTime.parse(sqlite_row['dueDate'])
          : null,
      createdAt: DateTime.parse(sqlite_row['createdAt']),
      isOffline: (sqlite_row['isOffline'] as int? ?? 0) == 1,
      isPendingUpdate: (sqlite_row['isPendingUpdate'] as int? ?? 0) == 1,
      isPendingDelete: (sqlite_row['isPendingDelete'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority,
      'category': category ?? 'Personal',
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isOffline': isOffline ? 1 : 0,
      'isPendingUpdate': isPendingUpdate ? 1 : 0,
      'isPendingDelete': isPendingDelete ? 1 : 0,
    };
  }

  Tasks copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    int? priority,
    String? category,
    DateTime? dueDate,
    DateTime? createdAt,
    bool? isOffline,
    bool? isPendingUpdate,
    bool? isPendingDelete,
  }) {
    return Tasks(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      isOffline: isOffline ?? this.isOffline,
      isPendingUpdate: isPendingUpdate ?? this.isPendingUpdate,
      isPendingDelete: isPendingDelete ?? this.isPendingDelete,
    );
  }
}

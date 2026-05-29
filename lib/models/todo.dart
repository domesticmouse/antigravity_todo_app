class SubTask {
  final int? id;
  final int todoId;
  final String title;
  final bool isCompleted;

  SubTask({
    this.id,
    required this.todoId,
    required this.title,
    this.isCompleted = false,
  });

  SubTask copyWith({int? id, int? todoId, String? title, bool? isCompleted}) {
    return SubTask(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'todo_id': todoId,
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'] as int?,
      todoId: map['todo_id'] as int,
      title: map['title'] as String,
      isCompleted: (map['is_completed'] as int) == 1,
    );
  }
}

class Todo {
  final int? id;
  final String title;
  final String description;
  final bool isCompleted;
  final int position;
  final List<SubTask> subTasks;

  Todo({
    this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.position = 0,
    this.subTasks = const [],
  });

  Todo copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    int? position,
    List<SubTask>? subTasks,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      position: position ?? this.position,
      subTasks: subTasks ?? this.subTasks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted ? 1 : 0,
      'position': position,
    };
  }

  factory Todo.fromMap(
    Map<String, dynamic> map, {
    List<SubTask> subTasks = const [],
  }) {
    return Todo(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      isCompleted: (map['is_completed'] as int) == 1,
      position: (map['position'] as int?) ?? 0,
      subTasks: subTasks,
    );
  }
}

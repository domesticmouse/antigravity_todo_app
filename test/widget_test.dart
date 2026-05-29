import 'package:flutter_test/flutter_test.dart';
import 'package:antigravity_todo_app/models/todo.dart';

void main() {
  group('SubTask Model Tests', () {
    test('toMap converts SubTask to a map correctly', () {
      final subtask = SubTask(
        id: 1,
        todoId: 10,
        title: 'Learn Riverpod',
        isCompleted: true,
      );

      final map = subtask.toMap();

      expect(map['id'], 1);
      expect(map['todo_id'], 10);
      expect(map['title'], 'Learn Riverpod');
      expect(map['is_completed'], 1);
    });

    test('fromMap parses SubTask from map correctly', () {
      final map = {
        'id': 2,
        'todo_id': 20,
        'title': 'Test widgets',
        'is_completed': 0,
      };

      final subtask = SubTask.fromMap(map);

      expect(subtask.id, 2);
      expect(subtask.todoId, 20);
      expect(subtask.title, 'Test widgets');
      expect(subtask.isCompleted, false);
    });

    test('copyWith copies properties correctly', () {
      final subtask = SubTask(
        id: 1,
        todoId: 10,
        title: 'Original title',
        isCompleted: false,
      );

      final updated = subtask.copyWith(
        title: 'Updated title',
        isCompleted: true,
      );

      expect(updated.id, 1);
      expect(updated.todoId, 10);
      expect(updated.title, 'Updated title');
      expect(updated.isCompleted, true);
    });
  });

  group('Todo Model Tests', () {
    test('toMap converts Todo to a map correctly', () {
      final todo = Todo(
        id: 100,
        title: 'Complete project',
        description: 'Finish all tasks and run verification',
        isCompleted: false,
      );

      final map = todo.toMap();

      expect(map['id'], 100);
      expect(map['title'], 'Complete project');
      expect(map['description'], 'Finish all tasks and run verification');
      expect(map['is_completed'], 0);
    });

    test('fromMap parses Todo from map correctly', () {
      final map = {
        'id': 101,
        'title': 'Celebrate success',
        'description': 'Buy coffee',
        'is_completed': 1,
      };

      final todo = Todo.fromMap(map);

      expect(todo.id, 101);
      expect(todo.title, 'Celebrate success');
      expect(todo.description, 'Buy coffee');
      expect(todo.isCompleted, true);
    });

    test('copyWith copies properties correctly', () {
      final todo = Todo(
        id: 5,
        title: 'Original Title',
        description: 'Original Desc',
        isCompleted: false,
        subTasks: [],
      );

      final subtasks = [SubTask(id: 1, todoId: 5, title: 'Subtask 1')];

      final updated = todo.copyWith(
        title: 'New Title',
        isCompleted: true,
        subTasks: subtasks,
      );

      expect(updated.id, 5);
      expect(updated.title, 'New Title');
      expect(updated.description, 'Original Desc');
      expect(updated.isCompleted, true);
      expect(updated.subTasks.length, 1);
      expect(updated.subTasks[0].title, 'Subtask 1');
    });
  });
}

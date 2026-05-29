import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:antigravity_todo_app/models/todo.dart';
import 'package:antigravity_todo_app/services/database_service.dart';

part 'todo_provider.g.dart';

enum TodoFilter { all, pending, completed }

@riverpod
class TodoFilterState extends _$TodoFilterState {
  @override
  TodoFilter build() => TodoFilter.all;

  void setFilter(TodoFilter filter) {
    state = filter;
  }
}

@riverpod
class SelectedTodoId extends _$SelectedTodoId {
  @override
  int? build() => null;

  void select(int? id) {
    state = id;
  }
}

@riverpod
class TodoList extends _$TodoList {
  final _dbService = DatabaseService.instance;

  @override
  FutureOr<List<Todo>> build() async {
    return await _dbService.fetchTodos();
  }

  Future<void> addTodo(String title) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final newTodo = Todo(title: title);
      await _dbService.insertTodo(newTodo);
      return await _dbService.fetchTodos();
    });
  }

  Future<void> toggleTodo(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentList = state.value ?? [];
      final todo = currentList.firstWhere((t) => t.id == id);
      final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
      await _dbService.updateTodo(updatedTodo);
      return await _dbService.fetchTodos();
    });
  }

  Future<void> updateTodoDescription(int id, String description) async {
    state = await AsyncValue.guard(() async {
      final currentList = state.value ?? [];
      final todo = currentList.firstWhere((t) => t.id == id);
      final updatedTodo = todo.copyWith(description: description);
      await _dbService.updateTodo(updatedTodo);
      return await _dbService.fetchTodos();
    });
  }

  Future<void> updateTodoTitle(int id, String title) async {
    state = await AsyncValue.guard(() async {
      final currentList = state.value ?? [];
      final todo = currentList.firstWhere((t) => t.id == id);
      final updatedTodo = todo.copyWith(title: title);
      await _dbService.updateTodo(updatedTodo);
      return await _dbService.fetchTodos();
    });
  }

  Future<void> deleteTodo(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dbService.deleteTodo(id);
      return await _dbService.fetchTodos();
    });
  }

  Future<void> reorderTodos(List<Todo> reorderedFilteredList) async {
    final currentList = state.value ?? [];
    final fullList = List<Todo>.from(currentList);

    final Set<int> filteredIds = reorderedFilteredList
        .map((t) => t.id!)
        .toSet();

    int insertIndex = fullList.indexWhere((t) => filteredIds.contains(t.id));
    if (insertIndex == -1) {
      insertIndex = 0;
    }

    fullList.removeWhere((t) => filteredIds.contains(t.id));
    fullList.insertAll(insertIndex, reorderedFilteredList);

    // Optimistic UI update
    state = AsyncValue.data(fullList);

    // Persist updated positions
    state = await AsyncValue.guard(() async {
      for (int i = 0; i < fullList.length; i++) {
        final updatedTodo = fullList[i].copyWith(position: i);
        await _dbService.updateTodo(updatedTodo);
      }
      return await _dbService.fetchTodos();
    });
  }

  // Subtask CRUD operations
  Future<void> addSubTask(int todoId, String title) async {
    state = await AsyncValue.guard(() async {
      final newSubTask = SubTask(todoId: todoId, title: title);
      await _dbService.insertSubTask(newSubTask);
      return await _dbService.fetchTodos();
    });
  }

  Future<void> toggleSubTask(SubTask subTask) async {
    state = await AsyncValue.guard(() async {
      final updatedSubTask = subTask.copyWith(
        isCompleted: !subTask.isCompleted,
      );
      await _dbService.updateSubTask(updatedSubTask);
      return await _dbService.fetchTodos();
    });
  }

  Future<void> updateSubTaskTitle(SubTask subTask, String title) async {
    state = await AsyncValue.guard(() async {
      final updatedSubTask = subTask.copyWith(title: title);
      await _dbService.updateSubTask(updatedSubTask);
      return await _dbService.fetchTodos();
    });
  }

  Future<void> deleteSubTask(int subTaskId) async {
    state = await AsyncValue.guard(() async {
      await _dbService.deleteSubTask(subTaskId);
      return await _dbService.fetchTodos();
    });
  }
}

@riverpod
List<Todo> filteredTodoList(Ref ref) {
  final todosAsync = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterStateProvider);

  return todosAsync.maybeWhen(
    data: (todos) {
      switch (filter) {
        case TodoFilter.all:
          return todos;
        case TodoFilter.pending:
          return todos.where((t) => !t.isCompleted).toList();
        case TodoFilter.completed:
          return todos.where((t) => t.isCompleted).toList();
      }
    },
    orElse: () => [],
  );
}

@riverpod
Todo? selectedTodo(Ref ref) {
  final todosAsync = ref.watch(todoListProvider);
  final selectedId = ref.watch(selectedTodoIdProvider);

  if (selectedId == null) return null;
  return todosAsync.maybeWhen(
    data: (todos) {
      try {
        return todos.firstWhere((t) => t.id == selectedId);
      } catch (_) {
        return null;
      }
    },
    orElse: () => null,
  );
}

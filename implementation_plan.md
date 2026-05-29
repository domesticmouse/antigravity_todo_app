# Implementation Plan - macOS Desktop Material 3 TODO App

This plan details the design and structure for building a premium macOS desktop TODO application using Flutter, Material 3, Riverpod for state management, and SQLite for local data persistence.

In accordance with your rules, **no source code files in your workspace will be modified directly by the assistant.** Instead, the assistant will provide clear instructions and code snippets for you to apply.

---

## Technical Stack & Dependencies

To implement this project, the following dependencies need to be added to `pubspec.yaml`:

1. **`flutter_riverpod`**: For state management.
2. **`sqflite`**: SQLite database engine for local persistence.
3. **`path_provider`**: To locate the correct database storage directory on macOS.
4. **`path`**: For secure cross-platform path construction.

---

## Proposed Database Schema

We will use a relational structure with two tables to support sub-tasks:

### `todos` Table
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique ID of the task |
| `title` | TEXT | NOT NULL | Task title |
| `description`| TEXT | | Optional notes / details |
| `is_completed`| INTEGER | NOT NULL (0 or 1) | Whether the task is completed |

### `subtasks` Table
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique ID of the sub-task |
| `todo_id` | INTEGER | NOT NULL, FOREIGN KEY (REFERENCES `todos(id)` ON DELETE CASCADE) | Association with parent task |
| `title` | TEXT | NOT NULL | Sub-task title |
| `is_completed`| INTEGER | NOT NULL (0 or 1) | Whether the sub-task is completed |

---

## Proposed Architecture

We will organize the code into clean, modular layers under `lib`:

```
lib/
├── main.dart                  # App initialization, main layout (Two-column structure)
├── models/
│   └── todo.dart              # Todo and SubTask data models (JSON serialization helper)
├── services/
│   └── database_service.dart  # SQLite operations (CRUD for todos & subtasks)
├── providers/
│   └── todo_provider.dart     # Riverpod StateNotifier to manage todo state
└── widgets/
    ├── sidebar.dart           # Sidebar filter (All, Pending, Completed)
    ├── todo_list_view.dart    # Task list with Material 3 styling
    └── todo_detail_panel.dart # Right-side sliding panel for details and sub-tasks
```

---

## Planned Code Implementations

We will guide you through the creation/modification of the following files:

### 1. `pubspec.yaml`
Add dependencies for Riverpod, sqflite, and path helper libraries.

### 2. `lib/models/todo.dart`
Define:
- `SubTask` with fields `id`, `todoId`, `title`, `isCompleted`.
- `Todo` with fields `id`, `title`, `description`, `isCompleted`, and `List<SubTask> subTasks`.
- Copy/clone helper methods (`copyWith`) to support immutable updates in Riverpod.

### 3. `lib/services/database_service.dart`
Initialize the SQLite database on macOS, and provide CRUD operations:
- `fetchTodos()`: Load all tasks with their subtasks using a SQL JOIN or multiple queries.
- `insertTodo()`, `updateTodo()`, `deleteTodo()`
- `insertSubTask()`, `updateSubTask()`, `deleteSubTask()`

### 4. `lib/providers/todo_provider.dart`
Expose:
- `TodoFilter`: Enum representing filters (All, Pending, Completed).
- `activeFilterProvider`: StateProvider to manage the active filter.
- `selectedTodoProvider`: StateProvider to manage which todo is currently selected (for the sliding detail panel).
- `todoListProvider`: StateNotifierProvider that manages loading/updating todos via the `DatabaseService`.

### 5. `lib/widgets/` Layout & UI Components
- **Sidebar**: List-based selector for filters.
- **Todo List**: Scrollable view of filtered tasks, complete button, and quick task insertion.
- **Detail Panel**: Desktop-friendly slide-out drawer or split-view section showing description editor and checkbox subtask checklist.

### 6. `lib/main.dart`
Re-write the main app file to use Riverpod `ProviderScope`, host the SQLite initialization inside `main()`, and arrange the screen layout using a row/split view containing `Sidebar`, `TodoListView`, and `TodoDetailPanel` side-by-side.

---

## Verification Plan

### Automated Verification
We will verify that:
1. `flutter pub get` runs successfully.
2. The project compiles without any static analysis errors using `dart analyze`.

### Manual Verification
Once implemented, we will verify:
- Creation of a new TODO.
- Appending sub-tasks and checking/unchecking them.
- Deleting the TODO (ensuring database cascades sub-tasks deletion).
- Switching filters in the sidebar.
- Persistence of state across application restarts.

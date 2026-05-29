# Implementation Plan - macOS Desktop Material 3 TODO App

This plan details the design and structure for building a premium macOS desktop TODO application using Flutter, Material 3, Riverpod (using modern code-generation), and SQLite for local data persistence.

The assistant will directly create and modify all necessary source code files in the workspace.

---

## Technical Stack & Dependencies

The following dependencies are defined in `pubspec.yaml`:

1. **`flutter_riverpod`** & **`riverpod_annotation`**: For modern reactive state management.
2. **`sqflite`**: SQLite database engine for local persistence.
3. **`path_provider`**: To locate the correct database storage directory on macOS.
4. **`path`**: For secure cross-platform path construction.
5. **`riverpod_generator`** & **`build_runner`**: (Dev dependencies) For code generation.

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
| `todo_id` | INTEGER | NOT NULL, FOREIGN KEY (todo_id) REFERENCES todos(id) ON DELETE CASCADE | Association with parent task |
| `title` | TEXT | NOT NULL | Sub-task title |
| `is_completed`| INTEGER | NOT NULL (0 or 1) | Whether the sub-task is completed |

---

## Proposed Architecture

We will organize the code into clean, modular layers under `lib`:

```
lib/
├── main.dart                  # App entry, Riverpod ProviderScope, and Desktop Window wrapper
├── models/
│   └── todo.dart              # Todo and SubTask data models (JSON serialization helper & copyWith)
├── services/
│   └── database_service.dart  # SQLite operations (CRUD for todos & subtasks with dual-query assembly)
├── providers/
│   └── todo_provider.dart     # Modern Riverpod Notifier classes (generated) managing filter/list/selected todo
└── widgets/
    ├── sidebar.dart           # Glassmorphic Sidebar filter (All, Pending, Completed) with counts
    ├── todo_list_view.dart    # Task list with Material 3 styling, hover effects, quick-add
    └── todo_detail_panel.dart # Sliding desktop detail panel for description & sub-tasks checklist
```

---

## Planned Code Implementations

We will create/modify the following files:

### 1. `lib/models/todo.dart`
Define:
- `SubTask` with fields `id`, `todoId`, `title`, `isCompleted`.
- `Todo` with fields `id`, `title`, `description`, `isCompleted`, and `List<SubTask> subTasks`.
- `copyWith` method on both classes to facilitate immutable state changes.

### 2. `lib/services/database_service.dart`
Initialize the SQLite database on macOS, and provide CRUD operations:
- `fetchTodos()`: Load all tasks and subtasks in two independent queries, joining in memory for optimal speed.
- CRUD operations for `Todo` and `SubTask` (insert, update, delete). Note that database constraints are configured with `ON DELETE CASCADE` to clean up subtasks automatically.

### 3. `lib/providers/todo_provider.dart`
Expose using Riverpod Generator:
- `TodoFilter`: Enum representing filters (All, Pending, Completed).
- `todoFilter`: `@riverpod` Notifier managing current active filter.
- `selectedTodoId`: `@riverpod` Notifier managing selected todo ID.
- `todoList`: `@riverpod` Notifier managing loading/updating todos via the `DatabaseService`.
- `filteredTodoList`: `@riverpod` Provider to automatically calculate filtered list of todos.

### 4. `lib/widgets/` Layout & UI Components
- **Sidebar**: Translucent glassmorphic panel with navigation list showing filters and item counts.
- **Todo List**: Scrollable view of filtered tasks, complete button, quick task insertion, hover animations.
- **Detail Panel**: Desktop-friendly sliding side panel showing description text area and dynamic subtask list.
- **Keyboard Shortcuts Listener**: High-level wrapper to capture `Cmd + N` (New task) and `Esc` (Close detail panel).

### 5. `lib/main.dart`
Initialize SQLite, wrap the app in Riverpod `ProviderScope`, and layout the screen in a clean 3-column split layout.

---

## Verification Plan

### Automated Verification
We will verify that:
1. `flutter pub get` runs successfully.
2. Code generation runs via `flutter pub run build_runner build --delete-conflicting-outputs`.
3. The project compiles without any static analysis errors using `dart analyze`.

### Manual Verification
Once implemented, we will verify:
- Creation of a new TODO.
- Appending sub-tasks and checking/unchecking them.
- Deleting the TODO (ensuring database cascades sub-tasks deletion).
- Switching filters in the sidebar.
- Persistence of state across application restarts.

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:antigravity_todo_app/models/todo.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbDirectory = await getApplicationDocumentsDirectory();
    final path = join(dbDirectory.path, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        is_completed INTEGER NOT NULL,
        position INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE subtasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        todo_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        is_completed INTEGER NOT NULL,
        FOREIGN KEY (todo_id) REFERENCES todos (id) ON DELETE CASCADE
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE todos ADD COLUMN position INTEGER DEFAULT 0',
      );
    }
  }

  // CRUD for Todos
  Future<Todo> insertTodo(Todo todo) async {
    final db = await database;

    // Shift positions up to make space for the new item at position 0
    await db.execute('UPDATE todos SET position = position + 1');

    final todoWithPos = todo.copyWith(position: 0);
    final id = await db.insert('todos', todoWithPos.toMap());

    // Save any initial subtasks
    for (final subTask in todo.subTasks) {
      await db.insert('subtasks', subTask.copyWith(todoId: id).toMap());
    }

    return fetchTodo(id);
  }

  Future<Todo> fetchTodo(int id) async {
    final db = await database;
    final maps = await db.query('todos', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      final todoMap = maps.first;
      final subtaskMaps = await db.query(
        'subtasks',
        where: 'todo_id = ?',
        whereArgs: [id],
      );
      final subTasks = subtaskMaps.map((map) => SubTask.fromMap(map)).toList();
      return Todo.fromMap(todoMap, subTasks: subTasks);
    } else {
      throw Exception('ID $id not found in database.');
    }
  }

  Future<List<Todo>> fetchTodos() async {
    final db = await database;
    final todoMaps = await db.query('todos', orderBy: 'position ASC, id DESC');
    final subtaskMaps = await db.query('subtasks');

    final Map<int, List<SubTask>> subtasksByTodoId = {};
    for (final map in subtaskMaps) {
      final subTask = SubTask.fromMap(map);
      subtasksByTodoId.putIfAbsent(subTask.todoId, () => []).add(subTask);
    }

    return todoMaps.map((map) {
      final id = map['id'] as int;
      return Todo.fromMap(map, subTasks: subtasksByTodoId[id] ?? []);
    }).toList();
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD for SubTasks
  Future<SubTask> insertSubTask(SubTask subTask) async {
    final db = await database;
    final id = await db.insert('subtasks', subTask.toMap());
    return subTask.copyWith(id: id);
  }

  Future<int> updateSubTask(SubTask subTask) async {
    final db = await database;
    return await db.update(
      'subtasks',
      subTask.toMap(),
      where: 'id = ?',
      whereArgs: [subTask.id],
    );
  }

  Future<int> deleteSubTask(int id) async {
    final db = await database;
    return await db.delete('subtasks', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}

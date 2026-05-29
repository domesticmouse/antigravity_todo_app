import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antigravity_todo_app/providers/todo_provider.dart';
import 'package:antigravity_todo_app/widgets/sidebar.dart';
import 'package:antigravity_todo_app/widgets/todo_list_view.dart';
import 'package:antigravity_todo_app/widgets/todo_detail_panel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Antigravity ToDo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        fontFamily: 'SF Pro Display', // premium system font style
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        fontFamily: 'SF Pro Display',
      ),
      themeMode: ThemeMode.system, // follow system light/dark theme
      home: const MainLayoutScreen(),
    );
  }
}

class MainLayoutScreen extends ConsumerWidget {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTodoId = ref.watch(selectedTodoIdProvider);

    return CallbackShortcuts(
      bindings: {
        // Cmd + N (macOS) / Ctrl + N (Fallback): Focus quick add task
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () {
          todoListViewKey.currentState?.focusQuickAdd();
        },
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          todoListViewKey.currentState?.focusQuickAdd();
        },
        // Escape: Deselect current todo (closes detail panel)
        const SingleActivator(LogicalKeyboardKey.escape): () {
          ref.read(selectedTodoIdProvider.notifier).select(null);
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Row(
            children: [
              // 1st Column: Glassmorphic Sidebar
              const Sidebar(),

              // 2nd Column: Task List View
              Expanded(child: TodoListView()),

              // 3rd Column: Sliding Task Details Panel
              if (selectedTodoId != null) const TodoDetailPanel(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antigravity_todo_app/models/todo.dart';
import 'package:antigravity_todo_app/providers/todo_provider.dart';

// Global key to allow triggering focus from parent (e.g. keyboard shortcuts)
final todoListViewKey = GlobalKey<_TodoListViewState>();

class TodoListView extends ConsumerStatefulWidget {
  TodoListView() : super(key: todoListViewKey);

  @override
  ConsumerState<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends ConsumerState<TodoListView> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void focusQuickAdd() {
    _focusNode.requestFocus();
  }

  void _submitTodo() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      ref.read(todoListProvider.notifier).addTodo(text);
      _textController.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(todoListProvider);
    final filteredTodos = ref.watch(filteredTodoListProvider);
    final selectedId = ref.watch(selectedTodoIdProvider);
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with stats
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Tasks',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '(${filteredTodos.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.hintColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Shortcut hint
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.hintColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '⌘N to write',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.hintColor.withValues(alpha: 0.8),
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Add Input Card
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Press Enter to quickly add a task...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: theme.colorScheme.primary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
              ),
              onSubmitted: (_) => _submitTodo(),
            ),
          ),
          const SizedBox(height: 24),

          // Task List Builder
          Expanded(
            child: todosAsync.when(
              data: (_) {
                if (filteredTodos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.hintColor.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle_outline_rounded,
                            size: 48,
                            color: theme.hintColor.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks in this view',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.hintColor.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enjoy your peace of mind!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: filteredTodos.length,
                  itemBuilder: (context, index) {
                    final todo = filteredTodos[index];
                    return _TodoItemCard(
                      key: ValueKey(todo.id),
                      index: index,
                      todo: todo,
                      isSelected: selectedId == todo.id,
                      onTap: () {
                        ref
                            .read(selectedTodoIdProvider.notifier)
                            .select(todo.id);
                      },
                    );
                  },
                  onReorderItem: (oldIndex, newIndex) {
                    final reordered = List<Todo>.from(filteredTodos);
                    final item = reordered.removeAt(oldIndex);
                    reordered.insert(newIndex, item);
                    ref.read(todoListProvider.notifier).reorderTodos(reordered);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Error loading tasks: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoItemCard extends StatefulWidget {
  final Todo todo;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  const _TodoItemCard({
    super.key,
    required this.todo,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  @override
  State<_TodoItemCard> createState() => _TodoItemCardState();
}

class _TodoItemCardState extends State<_TodoItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todo = widget.todo;
    final isCompleted = todo.isCompleted;

    final totalSubtasks = todo.subTasks.length;
    final completedSubtasks = todo.subTasks.where((s) => s.isCompleted).length;
    final hasSubtasks = totalSubtasks > 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Consumer(
        builder: (context, ref, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 10.0),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25)
                  : _isHovered
                  ? theme.colorScheme.surface
                  : theme.colorScheme.surface.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.4)
                    : _isHovered
                    ? theme.colorScheme.outlineVariant
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: [
                if (_isHovered || widget.isSelected)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.015),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      // Drag Handle (visible on hover)
                      ReorderableDragStartListener(
                        index: widget.index,
                        child: AnimatedOpacity(
                          opacity: _isHovered ? 0.6 : 0.0,
                          duration: const Duration(milliseconds: 100),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.drag_indicator_rounded,
                              size: 18,
                              color: theme.hintColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                      // Smooth-checking checkbox
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(todoListProvider.notifier)
                              .toggleTodo(todo.id!);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted
                                  ? theme.colorScheme.primary
                                  : theme.hintColor.withValues(alpha: 0.4),
                              width: 2,
                            ),
                            color: isCompleted
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                          ),
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Task contents
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todo.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isCompleted
                                    ? theme.hintColor.withValues(alpha: 0.7)
                                    : theme.textTheme.bodyLarge?.color,
                                fontWeight: widget.isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            if (hasSubtasks || todo.description.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  if (todo.description.isNotEmpty) ...[
                                    Icon(
                                      Icons.notes_rounded,
                                      size: 13,
                                      color: theme.hintColor.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  if (hasSubtasks) ...[
                                    if (todo.description.isNotEmpty)
                                      const SizedBox(width: 8),
                                    Icon(
                                      Icons.account_tree_outlined,
                                      size: 13,
                                      color: theme.hintColor.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$completedSubtasks/$totalSubtasks subtasks',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.hintColor.withValues(
                                              alpha: 0.7,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Animated hover actions (Delete)
                      AnimatedOpacity(
                        opacity: _isHovered ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 100),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              splashRadius: 18,
                              onPressed: () {
                                ref
                                    .read(todoListProvider.notifier)
                                    .deleteTodo(todo.id!);
                                if (widget.isSelected) {
                                  ref
                                      .read(selectedTodoIdProvider.notifier)
                                      .select(null);
                                }
                              },
                              color: theme.colorScheme.error.withValues(
                                alpha: 0.8,
                              ),
                              hoverColor: theme.colorScheme.errorContainer
                                  .withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

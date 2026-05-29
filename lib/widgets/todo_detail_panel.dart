import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antigravity_todo_app/models/todo.dart';
import 'package:antigravity_todo_app/providers/todo_provider.dart';

class TodoDetailPanel extends ConsumerStatefulWidget {
  const TodoDetailPanel({super.key});

  @override
  ConsumerState<TodoDetailPanel> createState() => _TodoDetailPanelState();
}

class _TodoDetailPanelState extends ConsumerState<TodoDetailPanel> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _newSubtaskController;
  final _descFocusNode = FocusNode();
  final _titleFocusNode = FocusNode();
  int? _lastTodoId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _newSubtaskController = TextEditingController();
    _descFocusNode.addListener(_onDescBlur);
    _titleFocusNode.addListener(_onTitleBlur);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _newSubtaskController.dispose();
    _descFocusNode.removeListener(_onDescBlur);
    _descFocusNode.dispose();
    _titleFocusNode.removeListener(_onTitleBlur);
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _onDescBlur() {
    if (!_descFocusNode.hasFocus && _lastTodoId != null) {
      ref
          .read(todoListProvider.notifier)
          .updateTodoDescription(_lastTodoId!, _descController.text.trim());
    }
  }

  void _onTitleBlur() {
    if (!_titleFocusNode.hasFocus && _lastTodoId != null) {
      final text = _titleController.text.trim();
      if (text.isNotEmpty) {
        ref.read(todoListProvider.notifier).updateTodoTitle(_lastTodoId!, text);
      }
    }
  }

  void _addSubtask(int todoId) {
    final text = _newSubtaskController.text.trim();
    if (text.isNotEmpty) {
      ref.read(todoListProvider.notifier).addSubTask(todoId, text);
      _newSubtaskController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final todo = ref.watch(selectedTodoProvider);
    final theme = Theme.of(context);

    if (todo == null) {
      _lastTodoId = null;
      return Container(
        width: 350,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            left: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.hintColor.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: 32,
                  color: theme.hintColor.withValues(alpha: 0.35),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No task selected',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.hintColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select a task to edit details',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Synchronize controllers when todo selection changes
    if (_lastTodoId != todo.id) {
      _lastTodoId = todo.id;
      _titleController.text = todo.title;
      _descController.text = todo.description;
    }

    final totalSubtasks = todo.subTasks.length;
    final completedSubtasks = todo.subTasks.where((s) => s.isCompleted).length;

    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () =>
                      ref.read(selectedTodoIdProvider.notifier).select(null),
                  splashRadius: 20,
                  tooltip: 'Close panel (Esc)',
                ),
                const Spacer(),
                Text(
                  'TASK DETAILS',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: theme.hintColor.withValues(alpha: 0.7),
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 40), // Balance closing button spacing
              ],
            ),
          ),
          const Divider(height: 1),

          // Main contents
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(28.0),
              children: [
                // Title
                TextField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  maxLines: null,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Task Title',
                    hintStyle: theme.textTheme.titleLarge?.copyWith(
                      color: theme.hintColor.withValues(alpha: 0.4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Description
                Text(
                  'NOTES',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.hintColor.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: theme.hintColor.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  child: TextField(
                    controller: _descController,
                    focusNode: _descFocusNode,
                    maxLines: 6,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Add details, description or notes...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor.withValues(alpha: 0.4),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Subtasks Section Header
                Row(
                  children: [
                    Text(
                      'SUB-TASKS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.hintColor.withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Spacer(),
                    if (totalSubtasks > 0)
                      Text(
                        '$completedSubtasks of $totalSubtasks',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subtask Checklist items
                if (todo.subTasks.isNotEmpty) ...[
                  ...todo.subTasks.map(
                    (subtask) => _SubTaskItem(
                      key: ValueKey(subtask.id),
                      subtask: subtask,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Quick Add Subtask Field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        size: 18,
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _newSubtaskController,
                          style: theme.textTheme.bodyMedium,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Add a subtask...',
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor.withValues(alpha: 0.4),
                            ),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _addSubtask(todo.id!),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubTaskItem extends ConsumerStatefulWidget {
  final SubTask subtask;

  const _SubTaskItem({super.key, required this.subtask});

  @override
  ConsumerState<_SubTaskItem> createState() => _SubTaskItemState();
}

class _SubTaskItemState extends ConsumerState<_SubTaskItem> {
  late TextEditingController _controller;
  final _focusNode = FocusNode();
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.subtask.title);
    _focusNode.addListener(_onBlur);
  }

  @override
  void didUpdateWidget(_SubTaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subtask.title != widget.subtask.title &&
        !_focusNode.hasFocus) {
      _controller.text = widget.subtask.title;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onBlur);
    _focusNode.dispose();
    super.dispose();
  }

  void _onBlur() {
    if (!_focusNode.hasFocus) {
      final text = _controller.text.trim();
      if (text.isNotEmpty && text != widget.subtask.title) {
        ref
            .read(todoListProvider.notifier)
            .updateSubTaskTitle(widget.subtask, text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = widget.subtask.isCompleted;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            // Subtask Checkbox
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isCompleted,
                onChanged: (_) {
                  ref
                      .read(todoListProvider.notifier)
                      .toggleSubTask(widget.subtask);
                },
                activeColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Subtask Title Editable Text Field
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted
                      ? theme.hintColor.withValues(alpha: 0.6)
                      : theme.textTheme.bodyMedium?.color,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                ),
                onSubmitted: (_) {
                  _focusNode.unfocus();
                },
              ),
            ),

            // Delete subtask button on hover
            if (_isHovered)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 14,
                onPressed: () {
                  ref
                      .read(todoListProvider.notifier)
                      .deleteSubTask(widget.subtask.id!);
                },
                color: theme.colorScheme.error.withValues(alpha: 0.7),
                tooltip: 'Delete subtask',
              )
            else
              const SizedBox(width: 16), // Reserve space to avoid shifting UI
          ],
        ),
      ),
    );
  }
}

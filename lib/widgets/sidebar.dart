import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antigravity_todo_app/providers/todo_provider.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(todoFilterStateProvider);
    final todosAsync = ref.watch(todoListProvider);

    final allCount = todosAsync.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );
    final pendingCount = todosAsync.maybeWhen(
      data: (list) => list.where((t) => !t.isCompleted).length,
      orElse: () => 0,
    );
    final completedCount = todosAsync.maybeWhen(
      data: (list) => list.where((t) => t.isCompleted).length,
      orElse: () => 0,
    );

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Title Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.deepPurple, Colors.indigo],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Antigravity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Sidebar items label
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    'FILTERS',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // Filter Items
                _SidebarItem(
                  icon: Icons.all_inbox_rounded,
                  label: 'All Tasks',
                  count: allCount,
                  isSelected: activeFilter == TodoFilter.all,
                  onTap: () => ref
                      .read(todoFilterStateProvider.notifier)
                      .setFilter(TodoFilter.all),
                  activeColor: Colors.deepPurple.shade400,
                ),
                const SizedBox(height: 4),
                _SidebarItem(
                  icon: Icons.circle_outlined,
                  label: 'Pending',
                  count: pendingCount,
                  isSelected: activeFilter == TodoFilter.pending,
                  onTap: () => ref
                      .read(todoFilterStateProvider.notifier)
                      .setFilter(TodoFilter.pending),
                  activeColor: Colors.amber.shade700,
                ),
                const SizedBox(height: 4),
                _SidebarItem(
                  icon: Icons.check_circle_rounded,
                  label: 'Completed',
                  count: completedCount,
                  isSelected: activeFilter == TodoFilter.completed,
                  onTap: () => ref
                      .read(todoFilterStateProvider.notifier)
                      .setFilter(TodoFilter.completed),
                  activeColor: Colors.green.shade600,
                ),

                const Spacer(),

                // Footer
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Local DB - SQLite',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = widget.isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: isSelected
                ? widget.activeColor.withValues(alpha: 0.15)
                : _isHovered
                ? theme.hoverColor.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? widget.activeColor.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: isSelected
                    ? widget.activeColor
                    : theme.iconTheme.color?.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? theme.textTheme.bodyLarge?.color
                        : theme.textTheme.bodyLarge?.color?.withValues(
                            alpha: 0.8,
                          ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? widget.activeColor.withValues(alpha: 0.2)
                      : theme.cardColor.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${widget.count}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? widget.activeColor
                        : theme.textTheme.labelSmall?.color?.withValues(
                            alpha: 0.6,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

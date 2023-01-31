import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kanban/data/entity/task_entity.dart';
import 'package:kanban/style/borders.dart';
import 'package:kanban/ui/widgets/space.dart';
import 'package:kanban/utils/context_ext.dart';
import 'package:kanban/utils/datetime/date_time_utils.dart';

class TaskItem extends StatelessWidget {
  const TaskItem({
    required this.task,
    this.showFooter = false,
    this.onTap,
    super.key,
  });

  final KTask task;
  final bool showFooter;
  final VoidCallback? onTap;

  bool get isComplete => task.completedAt != null;

  Duration get totalTimeSpent =>
      task.timerTotal == null ? Duration.zero : Duration(milliseconds: task.timerTotal!);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return Material(
      elevation: 2,
      type: MaterialType.card,
      color: theme.colorScheme.surface,
      borderRadius: Borders.roundedAll15,
      surfaceTintColor: theme.colorScheme.primary,
      child: InkWell(
        onTap: onTap,
        borderRadius: Borders.roundedAll15,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(theme),
              Text(
                formatTimestamp(task.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const VSpace(10),
              Text(
                task.content,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              if (showFooter && isComplete) _buildFooter(theme, localizations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title(ThemeData theme) {
    Widget widget = Text(
      task.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleMedium?.copyWith(
        decoration: isComplete ? TextDecoration.lineThrough : null,
      ),
    );
    if (task.isTimerActive) {
      widget = Row(
        children: [
          Expanded(child: widget),
          const Icon(Icons.pause),
        ],
      );
    }
    return widget;
  }

  Widget _buildFooter(ThemeData theme, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 25),
        Text(
          localizations.taskCompleteDate(formatTimestamp(task.completedAt!)),
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const VSpace(5),
        Text(
          localizations.taskTotalTime(formatDuration(totalTimeSpent)),
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        )
      ],
    );
  }
}

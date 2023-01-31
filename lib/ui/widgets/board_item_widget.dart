import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kanban/data/entity/board_entity.dart';
import 'package:kanban/style/borders.dart';
import 'package:kanban/ui/widgets/space.dart';
import 'package:kanban/utils/context_ext.dart';
import 'package:kanban/utils/datetime/date_time_utils.dart';

class BoardItem extends StatelessWidget {
  const BoardItem({required this.board, required this.onTap, super.key});

  final KBoard board;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Material(
      elevation: 2,
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
              Text(
                board.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                ),
              ),
              Text(
                formatTimestamp(board.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const VSpace(8),
              Text(
                board.description,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const VSpace(15),
              _membersCount(theme, context.localizations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _membersCount(ThemeData theme, AppLocalizations localizations) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Material(
        shape: const StadiumBorder(),
        color: theme.colorScheme.primary.withOpacity(0.15),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 12,
          ),
          child: Wrap(
            spacing: 10,
            children: [
              const Icon(Icons.people_rounded, size: 20),
              Text(
                localizations.boardMembersCount(board.members.length),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

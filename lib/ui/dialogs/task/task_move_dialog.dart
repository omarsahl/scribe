import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kanban/data/entity/task_entity.dart';
import 'package:kanban/data/entity/task_group_entity.dart';
import 'package:kanban/data/model/async/async_result.dart';
import 'package:kanban/di/di_config.dart';
import 'package:kanban/nav/navigator.dart';
import 'package:kanban/style/shapes.dart';
import 'package:kanban/ui/dialogs/task/task_move_store.dart';
import 'package:kanban/ui/widgets/error_view.dart';
import 'package:kanban/ui/widgets/progress.dart';
import 'package:kanban/ui/widgets/space.dart';
import 'package:kanban/utils/context_ext.dart';
import 'package:kanban/utils/mobx_ext.dart';
import 'package:kanban/utils/widget_ext.dart';
import 'package:mobx/mobx.dart';

class TaskMoveWidget extends StatefulObserverWidget {
  const TaskMoveWidget(this.task, {super.key});

  final KTask task;

  @override
  State<TaskMoveWidget> createState() => _TaskMoveWidgetState();
}

class _TaskMoveWidgetState extends State<TaskMoveWidget> {
  late final TaskMoveStore _store;
  late final ObservableStream<List<KTaskGroup>> _allGroupsStream;

  KTask get _task => widget.task;

  ReactionDisposer? _disposer;

  @override
  void initState() {
    super.initState();
    _store = getIt();
    _allGroupsStream = _store.getAllGroups(_task.boardId);
    _disposer = reaction((_) => _store.moveStatus, _handleStatus);
  }

  @override
  void dispose() {
    _disposer?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return Material(
      type: MaterialType.card,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            const VSpace.sliver(20),
            SliverToBoxAdapter(
              child: Text(
                localizations.moveTask,
                style: theme.textTheme.titleLarge,
              ),
            ),
            const VSpace.sliver(20),
            _groupSelector(),
            const VSpace.sliver(20),
          ],
        ),
      ),
    );
  }

  Widget _groupSelector() {
    return _allGroupsStream.when(
      onError: (_) => const SliverToBoxAdapter(
        child: ErrorView(),
      ),
      onLoading: () => const SliverToBoxAdapter(
        child: DefaultProgressIndicator.small(centered: true),
      ),
      onData: (groups) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: groups.length,
            (context, index) {
              final group = groups[index];
              return _GroupItem(
                group: group,
                onTap: () => _move(group.id),
                selected: _task.groupId == group.id,
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _move(String groupId) {
    return _store.moveTask(_task, groupId);
  }

  void _handleStatus(AsyncResult4<dynamic> result) {
    showSnackBarOnAsyncResultChanges(
      result: result,
      errorMessage: (_) => context.localizations.taskMoveError,
      successMessage: (_) => context.localizations.taskMoveSuccess,
      onSuccess: (_) => AppNavigator.pop(context),
    );
  }
}

class _GroupItem extends StatelessWidget {
  const _GroupItem({required this.group, required this.onTap, required this.selected, Key? key})
      : super(key: key);

  final KTaskGroup group;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = selected ? context.theme.colorScheme.secondaryContainer.withOpacity(0.5) : null;
    return ListTile(
      onTap: onTap,
      tileColor: backgroundColor,
      shape: Shapes.roundedShape10,
      leading: Container(
        width: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(group.color),
        ),
      ),
      title: Text(group.name),
    );
  }
}

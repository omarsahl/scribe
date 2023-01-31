import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kanban/data/entity/task_group_entity.dart';
import 'package:kanban/data/model/kanban.dart';
import 'package:kanban/di/di_config.dart';
import 'package:kanban/nav/navigator.dart';
import 'package:kanban/ui/board/board_store.dart';
import 'package:kanban/ui/dialogs/dialog_utils.dart';
import 'package:kanban/ui/dialogs/group/group_dialog.dart';
import 'package:kanban/ui/task/new_task_screen.dart';
import 'package:kanban/ui/task/task_screen.dart';
import 'package:kanban/ui/widgets/board_label_widget.dart';
import 'package:kanban/ui/widgets/empty_list_widget.dart';
import 'package:kanban/ui/widgets/error_view.dart';
import 'package:kanban/ui/widgets/progress.dart';
import 'package:kanban/ui/widgets/shimmer_widgets.dart';
import 'package:kanban/ui/widgets/space.dart';
import 'package:kanban/ui/widgets/task_item_widget.dart';
import 'package:kanban/utils/context_ext.dart';
import 'package:kanban/utils/mobx_ext.dart';
import 'package:mobx/mobx.dart';

class GroupWidget extends StatefulObserverWidget {
  const GroupWidget(this.groupId, this.boardId, {super.key});

  final String groupId;
  final String boardId;

  @override
  State<GroupWidget> createState() => _TaskGroupWidgetState();
}

class _TaskGroupWidgetState extends State<GroupWidget> {
  late BoardStore _store;
  late ObservableStream<GroupDetails> _detailsStream;

  @override
  void initState() {
    super.initState();
    _store = getIt();
    _detailsStream = _store.getGroupDetails(widget.groupId, widget.boardId);
  }

  @override
  Widget build(BuildContext context) {
    return _detailsStream.when(
      onData: _content,
      onLoading: _loadingView,
      onError: (e) => const ErrorView(),
    );
  }

  Widget _content(GroupDetails groupDetails) {
    return Column(
      children: [
        _header(groupDetails.group, groupDetails.tasks.length),
        Expanded(child: _tasksList(groupDetails)),
      ],
    );
  }

  Widget _header(KTaskGroup group, int tasksCount) {
    final theme = context.theme;
    return Row(
      children: [
        Flexible(
          child: BoardLabel(
            label: group.name,
            color: Color(group.color),
            onTap: () => _onTapGroupName(group),
          ),
        ),
        const HSpace(10),
        Material(
          shape: const CircleBorder(),
          color: theme.colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '$tasksCount',
              style: theme.textTheme.titleSmall,
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => _onTapCreateTask(group),
          icon: const Icon(Icons.add),
          tooltip: context.localizations.createTaskButtonText,
          style: IconButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: theme.colorScheme.secondaryContainer,
            foregroundColor: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        IconButton(
          onPressed: _onTapGroupMenu,
          icon: Icon(
            Icons.more_horiz,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _tasksList(GroupDetails groupDetails) {
    final tasks = groupDetails.tasks;
    if (tasks.isEmpty) {
      return EmptyListWidget(
        message: context.localizations.noTasksMessage,
      );
    }
    return ListView.separated(
      itemCount: tasks.length,
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskItem(
          task: task,
          onTap: () => _onTapTask(
            TaskDetails(task, groupDetails.group, groupDetails.board),
          ),
        );
      },
      separatorBuilder: (context, index) => const VSpace(10),
    );
  }

  Widget _loadingView() {
    return Column(
      children: [
        ShimmerContainer(
          child: Row(
            children: const [
              ShimmerRect(
                width: 85,
                height: 35,
                cornerRadius: 10,
              ),
              Spacer(),
              ShimmerCircle(radius: 22),
              HSpace(20),
            ],
          ),
        ),
        const Expanded(
          child: DefaultProgressIndicator.small(centered: true),
        ),
      ],
    );
  }

  void _onTapGroupName(KTaskGroup group) {
    newShowDialog(context, GroupActionsWidget.update(group));
  }

  void _onTapGroupMenu() {}

  void _onTapCreateTask(KTaskGroup group) {
    AppNavigator.push(
      context,
      const NewTaskScreenRoute(),
      args: NewTaskScreenInputArgs(group.id, group.boardId),
    );
  }

  void _onTapTask(TaskDetails taskDetails) {
    AppNavigator.push(
      context,
      const TaskScreenRoute(),
      args: TaskScreenInputArgs(
        taskDetails.task.id,
        taskDetails.group.id,
        taskDetails.boardDetails.board.id,
      ),
    );
  }
}

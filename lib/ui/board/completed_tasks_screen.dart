import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kanban/data/entity/task_entity.dart';
import 'package:kanban/di/di_config.dart';
import 'package:kanban/ui/board/history/completed_tasks_store.dart';
import 'package:kanban/ui/widgets/empty_list_widget.dart';
import 'package:kanban/ui/widgets/error_view.dart';
import 'package:kanban/ui/widgets/progress.dart';
import 'package:kanban/ui/widgets/space.dart';
import 'package:kanban/ui/widgets/task_item_widget.dart';
import 'package:kanban/utils/context_ext.dart';
import 'package:kanban/utils/mobx_ext.dart';
import 'package:mobx/mobx.dart';

class CompletedTasksScreen extends StatefulObserverWidget {
  const CompletedTasksScreen(this.boardId, {super.key});

  final String boardId;

  @override
  State<CompletedTasksScreen> createState() => _CompletedTasksScreenState();
}

class _CompletedTasksScreenState extends State<CompletedTasksScreen> {
  late final CompletedTaskStore _store;
  late final ObservableStream<List<KTask>> _tasksStream;

  @override
  void initState() {
    super.initState();
    _store = getIt();
    _tasksStream = _store.getCompletedTasks(widget.boardId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        titleSpacing: 5,
        backgroundColor: theme.colorScheme.background,
        title: Text(context.localizations.completedTasks),
      ),
      body: _content(),
    );
  }

  Widget _content() {
    return _tasksStream.when(
      onData: _buildTasksList,
      onError: (_) => const ErrorView(),
      onLoading: () => const DefaultProgressIndicator(centered: true),
    );
  }

  Widget _buildTasksList(List<KTask> tasks) {
    if (tasks.isEmpty) {
      return EmptyListWidget(
        message: context.localizations.noCompletedTasksMessage,
      );
    }
    return ListView.separated(
      itemCount: tasks.length,
      padding: const EdgeInsets.all(15),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskItem(
          task: task,
          showFooter: true,
        );
      },
      separatorBuilder: (context, index) => const VSpace(15),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kanban/core/logger/logger.dart';
import 'package:kanban/data/entity/task_entity.dart';
import 'package:kanban/data/model/async/async_result.dart';
import 'package:kanban/di/di_config.dart';
import 'package:kanban/nav/navigator.dart';
import 'package:kanban/style/animation.dart';
import 'package:kanban/style/borders.dart';
import 'package:kanban/ui/dialogs/dialog_utils.dart';
import 'package:kanban/ui/dialogs/task/task_move_dialog.dart';
import 'package:kanban/ui/task/task_store.dart';
import 'package:kanban/ui/widgets/error_view.dart';
import 'package:kanban/ui/widgets/progress.dart';
import 'package:kanban/ui/widgets/space.dart';
import 'package:kanban/ui/widgets/textfield/text_field.dart';
import 'package:kanban/utils/context_ext.dart';
import 'package:kanban/utils/mobx_ext.dart';
import 'package:kanban/utils/widget_ext.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart';

@immutable
class TaskScreenInputArgs {
  const TaskScreenInputArgs(this.taskId, this.groupId, this.boardId);

  final String taskId;
  final String groupId;
  final String boardId;
}

class TaskScreen extends StatefulWidget {
  const TaskScreen(this.args, {super.key});

  final TaskScreenInputArgs args;

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late final TaskStore _store;
  late final TextEditingController _nameController;
  late final TextEditingController _contentController;
  late final TaskScreenInputArgs args = widget.args;
  final CompositeSubscription _subscriptions = CompositeSubscription();

  ReactionDisposer? _taskUpdateDisposer;
  ReactionDisposer? _timerUpdateDisposer;

  @override
  void initState() {
    super.initState();
    _store = getIt();
    _store.init(args.taskId, args.boardId);
    _taskUpdateDisposer = reaction((_) => _store.upsertStatus, _handleUpdateResult);
    _timerUpdateDisposer = reaction((_) => _store.timerChangesStatus, _handleTimerStatus);
    _nameController = TextEditingController()
      ..addListener(() => _store.nameState.setText(_nameController.text));
    _contentController = TextEditingController()
      ..addListener(() => _store.contentState.setText(_contentController.text));
    _store.taskStream.listen((task) {
      _nameController.text = task.name;
      _contentController.text = task.content;
    }).addTo(_subscriptions);
  }

  @override
  void dispose() {
    _taskUpdateDisposer?.call();
    _timerUpdateDisposer?.call();
    _subscriptions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Observer(
        builder: (context) {
          final stream = _store.taskStream;
          return stream.when(
            onError: (_) => const ErrorView(),
            onLoading: () => const DefaultProgressIndicator(centered: true),
            onData: (task) {
              logger.e(task);
              return Scaffold(
                appBar: _appBar(task),
                body: _content(task),
              );
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _appBar(KTask task) {
    final localizations = context.localizations;
    return AppBar(
      titleSpacing: 0,
      automaticallyImplyLeading: true,
      title: Text(localizations.taskScreenTitle),
      actions: [
        IconButton(
          onPressed: () => _move(task),
          tooltip: localizations.moveTask,
          icon: const Icon(Icons.drive_file_move),
        ),
      ],
    );
  }

  Widget _content(KTask task) {
    final localizations = context.localizations;
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
      child: Column(
        children: [
          KTextField(
            state: _store.nameState,
            controller: _nameController,
            hint: localizations.taskNameDefault,
            fieldName: localizations.taskNameHint,
            keyboardType: TextInputType.multiline,
          ),
          const VSpace(15),
          Expanded(
            child: KTextField(
              expands: true,
              maxLines: null,
              state: _store.contentState,
              controller: _contentController,
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
              hint: localizations.taskContentHint,
            ),
          ),
          const VSpace(15),
          _buildTimerControls(task),
          const VSpace(15),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildTimerControls(KTask task) {
    final theme = context.theme;
    final localizations = context.localizations;
    return Material(
      borderRadius: Borders.roundedAll10,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.taskTimerLabel,
                    style: theme.textTheme.labelLarge,
                  ),
                  Text(
                    task.isTimerActive
                        ? localizations.taskTimerStatusActive
                        : localizations.taskTimerStatusInactive,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _toggleTimer(task),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              icon: AnimatedSwitcher(
                duration: defaultAnimationDuration,
                switchInCurve: Curves.easeInQuart,
                switchOutCurve: Curves.easeOutBack,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  task.isTimerActive ? Icons.pause : Icons.play_arrow,
                  key: ValueKey(task.isTimerActive),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Observer(
      builder: (context) {
        final enabled = !_store.upsertStatus.isLoading && _store.validInputs;
        return Row(
          children: [
            Expanded(
              child: FilledButton.tonal(
                onPressed: enabled ? _complete : null,
                child: Text(context.localizations.completeTask),
              ),
            ),
            const HSpace(15),
            Expanded(
              child: FilledButton(
                onPressed: enabled ? _save : null,
                child: Text(context.localizations.save),
              ),
            ),
          ],
        );
      },
    );
  }

  void _save() {
    _store.createTask(args.groupId, args.boardId);
  }

  void _complete() {
    _store.updateTask(args.taskId, args.boardId, true);
  }

  void _move(KTask task) {
    newShowDialog(context, TaskMoveWidget(task));
  }

  void _toggleTimer(KTask task) {
    _store.toggleTimer(task);
  }

  void _handleUpdateResult(AsyncResult4<void> result) {
    showSnackBarOnAsyncResultChanges(
      result: result,
      successMessage: (_) => context.localizations.updatesSaved,
      onSuccess: (_) => AppNavigator.pop(context),
    );
  }

  void _handleTimerStatus(AsyncResult4<bool> result) {
    showSnackBarOnAsyncResultChanges(
      result: result,
      successMessage: (started) {
        if (started) {
          return context.localizations.taskTimerStarted;
        }
        return context.localizations.taskTimerStopped;
      },
    );
  }
}

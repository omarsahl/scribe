import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kanban/data/model/async/async_result.dart';
import 'package:kanban/di/di_config.dart';
import 'package:kanban/nav/navigator.dart';
import 'package:kanban/ui/task/task_store.dart';
import 'package:kanban/ui/widgets/space.dart';
import 'package:kanban/ui/widgets/textfield/text_field.dart';
import 'package:kanban/utils/context_ext.dart';
import 'package:kanban/utils/widget_ext.dart';
import 'package:mobx/mobx.dart';

@immutable
class NewTaskScreenInputArgs {
  const NewTaskScreenInputArgs(this.groupId, this.boardId);

  final String groupId;
  final String boardId;
}

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen(this.args, {Key? key}) : super(key: key);

  final NewTaskScreenInputArgs args;

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  late final TaskStore _store;
  late final TextEditingController _nameController;
  late final TextEditingController _contentController;

  late NewTaskScreenInputArgs args = widget.args;

  ReactionDisposer? _newTaskDisposer;

  @override
  void initState() {
    super.initState();
    _store = getIt();
    _newTaskDisposer = reaction((_) => _store.upsertStatus, _handleNewTaskResult);
    _nameController = TextEditingController()
      ..addListener(() => _store.nameState.setText(_nameController.text));
    _contentController = TextEditingController()
      ..addListener(() => _store.contentState.setText(_contentController.text));
  }

  @override
  void dispose() {
    _newTaskDisposer?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _content(),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      titleSpacing: 0,
      automaticallyImplyLeading: true,
      title: Text(context.localizations.taskScreenTitle),
    );
  }

  Widget _content() {
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
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Observer(
      builder: (context) {
        final enabled = !_store.upsertStatus.isLoading && _store.validInputs;
        return FilledButton(
          onPressed: enabled ? _save : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(40),
          ),
          child: Text(context.localizations.save),
        );
      },
    );
  }

  void _save() {
    _store.createTask(args.groupId, args.boardId);
  }

  void _handleNewTaskResult(AsyncResult4<void> result) {
    showSnackBarOnAsyncResultChanges(
      result: result,
      successMessage: (_) => context.localizations.taskCreated,
      onSuccess: (_) => AppNavigator.pop(context),
    );
  }
}

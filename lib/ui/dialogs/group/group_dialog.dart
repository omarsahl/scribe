import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kanban/data/entity/task_group_entity.dart';
import 'package:kanban/data/model/async/async_result.dart';
import 'package:kanban/di/di_config.dart';
import 'package:kanban/nav/navigator.dart';
import 'package:kanban/style/colors.dart';
import 'package:kanban/ui/dialogs/group/group_actions_store.dart';
import 'package:kanban/ui/widgets/color_preview.dart';
import 'package:kanban/ui/widgets/space.dart';
import 'package:kanban/ui/widgets/textfield/text_field.dart';
import 'package:kanban/utils/context_ext.dart';
import 'package:kanban/utils/widget_ext.dart';
import 'package:mobx/mobx.dart';

class GroupActionsWidget extends StatefulObserverWidget {
  const GroupActionsWidget.create(this.boardId, {super.key}) : group = null;

  GroupActionsWidget.update(KTaskGroup this.group, {super.key}) : boardId = group.boardId;

  final String boardId;
  final KTaskGroup? group;

  @override
  State<GroupActionsWidget> createState() => _GroupActionsWidgetState();
}

class _GroupActionsWidgetState extends State<GroupActionsWidget> {
  late final GroupActionsStore _store;
  late final TextEditingController _nameController;

  bool get _isUpdate => widget.group != null;

  KTaskGroup get _oldGroup => widget.group!;

  ReactionDisposer? _disposer;

  @override
  void initState() {
    super.initState();
    _store = getIt();
    _disposer = reaction((_) => _store.status, _handleStatus);
    _nameController = TextEditingController()
      ..addListener(() => _store.nameState.setText(_nameController.text));
    if (_isUpdate) {
      _nameController.text = _oldGroup.name;
      _store.setSelectedColor(Color(_oldGroup.color));
    }
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
                _isUpdate ? localizations.updateGroupDialogLabel : localizations.newGroupDialogLabel,
                style: theme.textTheme.titleLarge,
              ),
            ),
            const VSpace.sliver(20),
            SliverToBoxAdapter(child: _nameField()),
            const VSpace.sliver(15),
            _colorSelector(),
            const VSpace.sliver(15),
            SliverToBoxAdapter(child: _submitButton(localizations)),
            const VSpace.sliver(20),
          ],
        ),
      ),
    );
  }

  Widget _nameField() {
    final localizations = context.localizations;
    return KTextField(
      maxLines: 1,
      state: _store.nameState,
      controller: _nameController,
      hint: localizations.newGroupDialogNameHint,
    );
  }

  Widget _colorSelector() {
    // Access it here in order for the mobx observer to pick it up.
    final selectedColor = _store.selectedColor;
    return SliverGrid.builder(
      itemCount: LabelColors.all.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.7,
      ),
      itemBuilder: (context, index) {
        final color = LabelColors.all[index];
        return ColorPreviewWidget(
          color: color,
          key: ValueKey(color),
          selected: selectedColor == color,
          onTap: () => _store.setSelectedColor(color),
        );
      },
    );
  }

  Widget _submitButton(AppLocalizations localizations) {
    final onTap = _isUpdate ? _update : _create;
    final enabled = !_store.status.isLoading && _store.validInputs;
    return FilledButton(
      onPressed: enabled ? onTap : null,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(40),
      ),
      child: Text(localizations.submit),
    );
  }

  Future<void> _create() {
    return _store.createGroup(widget.boardId);
  }

  Future<void> _update() {
    return _store.updateGroup(_oldGroup.id, widget.boardId);
  }

  void _handleStatus(AsyncResult4<dynamic> result) {
    showSnackBarOnAsyncResultChanges(
      result: result,
      successMessage: (_) => context.localizations.updatesSaved,
      onSuccess: (_) => AppNavigator.pop(context),
    );
  }
}

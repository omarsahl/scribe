import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kanban/data/model/async/async_result.dart';
import 'package:kanban/di/di_config.dart';
import 'package:kanban/nav/navigator.dart';
import 'package:kanban/ui/dialogs/board/create_board_store.dart';
import 'package:kanban/ui/widgets/space.dart';
import 'package:kanban/ui/widgets/textfield/text_field.dart';
import 'package:kanban/utils/context_ext.dart';
import 'package:kanban/utils/widget_ext.dart';
import 'package:mobx/mobx.dart';

class CreateBoardWidget extends StatefulObserverWidget {
  const CreateBoardWidget({Key? key}) : super(key: key);

  @override
  State<CreateBoardWidget> createState() => _CreateBoardWidgetState();
}

class _CreateBoardWidgetState extends State<CreateBoardWidget> {
  late final CreateBoardStore _store;

  ReactionDisposer? _disposer;

  @override
  void initState() {
    super.initState();
    _store = getIt();
    _disposer = reaction((_) => _store.newBoardStatus, _handleResult);
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
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.newBoardDialogLabel,
              style: theme.textTheme.titleLarge,
            ),
            const VSpace(20),
            KTextField(
              maxLines: 1,
              state: _store.nameState,
              hint: localizations.newBoardDialogNameHint,
            ),
            const VSpace(15),
            KTextField(
              maxLines: 5,
              minCharacters: 5,
              maxCharacters: 200,
              showCounter: true,
              state: _store.descriptionState,
              hint: localizations.newBoardDialogDescriptionHint,
            ),
            const VSpace(15),
            _submitButton(localizations),
          ],
        ),
      ),
    );
  }

  Widget _submitButton(AppLocalizations localizations) {
    return FilledButton(
      onPressed: !_store.newBoardStatus.isLoading && _store.validInputs ? _onTapCreate : null,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(40),
      ),
      child: Text(localizations.newBoardDialogCreateButtonText),
    );
  }

  Future<void> _onTapCreate() {
    return _store.createBoard();
  }

  void _handleResult(AsyncResult4<dynamic> result) {
    showSnackBarOnAsyncResultChanges(
      result: result,
      successMessage: (_) => context.localizations.updatesSaved,
      onSuccess: (_) => AppNavigator.pop(context),
    );
  }
}

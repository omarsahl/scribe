import 'package:injectable/injectable.dart';
import 'package:kanban/core/logger/logger.dart';
import 'package:kanban/data/kanban_repository.dart';
import 'package:kanban/data/model/async/async_result.dart';
import 'package:kanban/di/scopes/home_screen_scope.dart';
import 'package:kanban/ui/widgets/textfield/text_field_state.dart';
import 'package:mobx/mobx.dart';

part 'create_board_store.g.dart';

@injectable
@homeScreenScope
class CreateBoardStore = _CreateBoardStore with _$CreateBoardStore;

abstract class _CreateBoardStore with Store {
  _CreateBoardStore(this._repo);

  final KRepository _repo;

  final TextFieldStateStore nameState = TextFieldStateStore(validator: notBlankValidator);
  final TextFieldStateStore descriptionState = TextFieldStateStore(validator: notBlankValidator);

  @computed
  bool get validInputs => nameState.isValid && descriptionState.isValid;

  @readonly
  AsyncResult4<void> _newBoardStatus = const AsyncResult4.idle();

  @action
  Future<void> createBoard() async {
    if (_newBoardStatus.isLoading || !validInputs) {
      return;
    }
    _newBoardStatus = const AsyncResult4.loading();
    try {
      _newBoardStatus = AsyncResult4.success(
        await _repo.createBoard(nameState.text, descriptionState.text),
      );
    } catch (e, s) {
      logger.e('Error creating new board', e, s);
      _newBoardStatus = AsyncResult4.error(e, s);
    }
  }
}

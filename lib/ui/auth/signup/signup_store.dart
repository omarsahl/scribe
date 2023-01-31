import 'package:injectable/injectable.dart';
import 'package:kanban/auth/auth_manager.dart';
import 'package:kanban/auth/models/sign_up_params.dart';
import 'package:kanban/core/logger/logger.dart';
import 'package:kanban/data/entity/user_entity.dart';
import 'package:kanban/data/model/async/async_result.dart';
import 'package:kanban/di/scopes/auth_screen_scope.dart';
import 'package:kanban/ui/widgets/textfield/text_field_state.dart';
import 'package:mobx/mobx.dart';

part 'signup_store.g.dart';

@singleton
@authScreenScope
class SignUpStore = _SignUpStore with _$SignUpStore;

abstract class _SignUpStore with Store {
  _SignUpStore(this._authManager);

  final AuthManager _authManager;

  final TextFieldStateStore nameState = TextFieldStateStore(validator: notBlankValidator);

  final TextFieldStateStore emailState = TextFieldStateStore(
    validator: (value) {
      if (value.trim().isEmpty) {
        return TextFieldValidationError.empty;
      }
      if (!emailRegex.hasMatch(value)) {
        return TextFieldValidationError.invalidFormat;
      }
      return null;
    },
  );

  final TextFieldStateStore passwordState = TextFieldStateStore(
    validator: (value) {
      if (value.isEmpty) {
        return TextFieldValidationError.empty;
      }
      if (value.length < 6) {
        return TextFieldValidationError.invalidLength;
      }
      return null;
    },
  );

  @readonly
  AsyncResult4<KUser> _authResult = const AsyncResult4.idle();

  @computed
  bool get loading => _authResult.isLoading;

  @computed
  bool get validInputs => nameState.isValid && emailState.isValid && passwordState.isValid;

  @computed
  bool get submitEnabled => !loading && validInputs;

  @action
  Future<void> signUp(SignUpParams params) async {
    _authResult = const AsyncResult4.loading();
    try {
      final result = await _authManager.signUp(params);
      _authResult = AsyncResult4.success(result);
    } catch (e, s) {
      logger.e("Error signing up", e, s);
      _authResult = AsyncResult4.error(e, s);
    }
  }
}

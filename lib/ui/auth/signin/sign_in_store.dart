import 'package:injectable/injectable.dart';
import 'package:kanban/auth/auth_manager.dart';
import 'package:kanban/auth/models/auth_params.dart';
import 'package:kanban/core/logger/logger.dart';
import 'package:kanban/data/entity/user_entity.dart';
import 'package:kanban/data/model/async/async_result.dart';
import 'package:kanban/di/scopes/auth_screen_scope.dart';
import 'package:kanban/ui/widgets/textfield/text_field_state.dart';
import 'package:mobx/mobx.dart';

part 'sign_in_store.g.dart';

@singleton
@authScreenScope
class SignInStore = _SignInStore with _$SignInStore;

abstract class _SignInStore with Store {
  final AuthManager _authManager;

  _SignInStore(this._authManager);

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
      return null;
    },
  );

  @readonly
  AsyncResult4<KUser> _authResult = const AsyncResult4.idle();

  @computed
  bool get loading => _authResult.isLoading;

  @computed
  bool get validInputs => emailState.isValid && passwordState.isValid;

  @computed
  bool get submitEnabled => !loading && validInputs;

  @action
  Future<void> login(AuthProviderParams params) async {
    _authResult = const AsyncResult4.loading();
    try {
      final result = await _authManager.logIn(params);
      _authResult = AsyncResult4.success(result);
    } catch (e, s) {
      logger.e("Error logging in", e, s);
      _authResult = AsyncResult4.error(e, s);
    }
  }
}

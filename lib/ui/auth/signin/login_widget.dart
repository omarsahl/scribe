import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kanban/auth/models/auth_params.dart';
import 'package:kanban/di/di_config.dart';
import 'package:kanban/ui/auth/signin/sign_in_store.dart';
import 'package:kanban/ui/widgets/progress.dart';
import 'package:kanban/ui/widgets/space.dart';
import 'package:kanban/ui/widgets/textfield/validation_error_extension.dart';
import 'package:kanban/utils/context_ext.dart';

typedef LoginCallback = Function(AuthProviderParams params);

class AuthScreenLoginWidget extends StatefulWidget {
  const AuthScreenLoginWidget({required this.onLogin, Key? key}) : super(key: key);

  final LoginCallback onLogin;

  @override
  State<AuthScreenLoginWidget> createState() => _AuthScreenLoginWidgetState();
}

class _AuthScreenLoginWidgetState extends State<AuthScreenLoginWidget> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  late final SignInStore _store;

  String get email => _emailController.text;

  String get password => _passwordController.text;

  @override
  void initState() {
    super.initState();
    _store = getIt();
    _emailController = TextEditingController()..addListener(() => _store.emailState.setText(email));
    _passwordController = TextEditingController()..addListener(() => _store.passwordState.setText(password));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.signInLabel,
          style: theme.textTheme.titleSmall,
        ),
        const VSpace(15),
        _buildEmailInput(),
        const VSpace(15),
        _buildPasswordInput(),
        const VSpace(25),
        _buildLoginButton(),
      ],
    );
  }

  Widget _buildEmailInput() {
    return Observer(builder: (context) {
      final localizations = context.localizations;
      return TextField(
        maxLines: 1,
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          filled: true,
          hintText: context.localizations.emailHint,
          prefixIcon: const Icon(Icons.email_rounded),
          errorText: _store.emailState.error?.errorType.getLocalizedMessage(
            localizations,
            localizations.emailHint,
          ),
        ),
      );
    });
  }

  Widget _buildPasswordInput() {
    return Observer(builder: (context) {
      final localizations = context.localizations;
      return TextField(
        maxLines: 1,
        obscureText: true,
        controller: _passwordController,
        decoration: InputDecoration(
          filled: true,
          hintText: context.localizations.passwordHint,
          prefixIcon: const Icon(Icons.lock_rounded),
          errorText: _store.passwordState.error?.errorType.getLocalizedMessage(
            localizations,
            localizations.passwordHint,
          ),
        ),
      );
    });
  }

  Widget _buildLoginButton() {
    return Observer(builder: (context) {
      final theme = context.theme;
      final buttonChild = _store.loading
          ? DefaultProgressIndicator.small(color: theme.colorScheme.onPrimary)
          : Text(context.localizations.signInButtonText);
      return FilledButton(
        onPressed: _store.submitEnabled ? _onTapLogin : null,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(40),
        ),
        child: buttonChild,
      );
    });
  }

  void _onTapLogin() {
    widget.onLogin(
      AuthProviderParams.credentials(email, password),
    );
  }
}

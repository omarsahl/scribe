import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kanban/auth/models/sign_up_params.dart';
import 'package:kanban/di/di_config.dart';
import 'package:kanban/ui/auth/signup/signup_store.dart';
import 'package:kanban/ui/widgets/progress.dart';
import 'package:kanban/ui/widgets/space.dart';
import 'package:kanban/ui/widgets/textfield/validation_error_extension.dart';
import 'package:kanban/utils/context_ext.dart';

typedef SignUpInputsCallback = Function(SignUpParams params);

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({
    required this.onSignUp,
    required this.onSignIn,
    Key? key,
  }) : super(key: key);

  final SignUpInputsCallback onSignUp;
  final VoidCallback onSignIn;

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  late final SignUpStore _store;

  String get name => _nameController.text;

  String get email => _emailController.text;

  String get password => _passwordController.text;

  @override
  void initState() {
    super.initState();
    _store = getIt();
    _nameController = TextEditingController()..addListener(() => _store.nameState.setText(name));
    _emailController = TextEditingController()..addListener(() => _store.emailState.setText(email));
    _passwordController = TextEditingController()..addListener(() => _store.passwordState.setText(password));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            context.localizations.signUpLabel,
            style: context.theme.textTheme.titleSmall,
          ),
        ),
        const VSpace(15),
        _buildNameInput(),
        const VSpace(15),
        _buildEmailInput(),
        const VSpace(15),
        _buildPasswordInput(),
        const VSpace(25),
        _buildSignUpButton(),
        const VSpace(10),
        _buildSignInButton(),
      ],
    );
  }

  Widget _buildNameInput() {
    return Observer(builder: (context) {
      final localizations = context.localizations;
      return TextField(
        maxLines: 1,
        controller: _nameController,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          filled: true,
          hintText: localizations.nameHint,
          prefixIcon: const Icon(Icons.account_circle_rounded),
          errorText: _store.nameState.error?.errorType.getLocalizedMessage(
            localizations,
            localizations.nameHint,
          ),
        ),
      );
    });
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
          hintText: localizations.emailHint,
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
          errorText: _store.passwordState.error?.errorType
              .getLocalizedMessage(localizations, localizations.passwordHint, 6, 25),
        ),
      );
    });
  }

  Widget _buildSignUpButton() {
    return Observer(builder: (context) {
      final theme = context.theme;
      return FilledButton(
        onPressed: _store.submitEnabled ? _onTapSignUp : null,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(40),
        ),
        child: _store.loading
            ? DefaultProgressIndicator.small(color: theme.colorScheme.onPrimary)
            : Text(context.localizations.signUpButtonText),
      );
    });
  }

  Widget _buildSignInButton() {
    return TextButton(
      onPressed: _store.loading ? null : widget.onSignIn,
      style: TextButton.styleFrom(
        foregroundColor: context.theme.colorScheme.onSurface.withOpacity(0.8),
      ),
      child: Text(context.localizations.signInInsteadLabel),
    );
  }

  void _onTapSignUp() {
    widget.onSignUp(SignUpParams(name, email, password));
  }
}

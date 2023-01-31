import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kanban/auth/models/auth_params.dart';
import 'package:kanban/auth/models/sign_up_params.dart';
import 'package:kanban/data/entity/user_entity.dart';
import 'package:kanban/data/model/async/async_result.dart';
import 'package:kanban/di/di_config.dart';
import 'package:kanban/di/scopes/auth_screen_scope.dart';
import 'package:kanban/exceptions/auth/auth_exception.dart';
import 'package:kanban/nav/navigator.dart';
import 'package:kanban/ui/auth/signin/login_widget.dart';
import 'package:kanban/ui/auth/signin/sign_in_store.dart';
import 'package:kanban/ui/auth/signup/sign_up_widget.dart';
import 'package:kanban/ui/auth/signup/signup_store.dart';
import 'package:kanban/ui/auth/widgets/google_sign_in_button.dart';
import 'package:kanban/ui/widgets/space.dart';
import 'package:kanban/utils/context_ext.dart';
import 'package:kanban/utils/snack_bar_ext.dart';
import 'package:mobx/mobx.dart';

enum _AuthScreenContentType { idle, signIn, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  _AuthScreenContentType _contentType = _AuthScreenContentType.idle;
  ReactionDisposer? _loginDisposer;
  ReactionDisposer? _signUpDisposer;

  late SignInStore _signInStore;
  late SignUpStore _signUpStore;

  Widget get _visibleContent {
    switch (_contentType) {
      case _AuthScreenContentType.idle:
        return _buildLoginLayout();
      case _AuthScreenContentType.signIn:
        return _buildLoginLayout();
      case _AuthScreenContentType.signUp:
        return _buildSignUpLayout();
    }
  }

  @override
  void initState() {
    super.initState();
    initAuthScreenScope();
    _signInStore = getIt();
    _signUpStore = getIt();
    _loginDisposer = reaction((_) => _signInStore.authResult, handleAuthResult);
    _signUpDisposer = reaction((_) => _signUpStore.authResult, handleAuthResult);
  }

  @override
  void dispose() {
    _loginDisposer?.call();
    _signUpDisposer?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;
    final localizations = context.localizations;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20) + EdgeInsets.only(top: context.mediaQuery.padding.top),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    localizations.helloMessage,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const HSpace(15),
                  SvgPicture.asset(
                    'assets/svg/emoji_u1f44b.svg',
                    height: 40,
                  ),
                ],
              ),
              const VSpace(20),
              Text(
                localizations.welcomeToMessage,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 25,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                localizations.appName,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                ),
              ),
              const VSpace(25),
              PageTransitionSwitcher(
                duration: const Duration(milliseconds: 500),
                layoutBuilder: (List<Widget> entries) => Stack(
                  alignment: Alignment.topLeft,
                  children: entries,
                ),
                transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                  return SharedAxisTransition(
                    animation: primaryAnimation,
                    secondaryAnimation: secondaryAnimation,
                    fillColor: theme.colorScheme.surface,
                    transitionType: SharedAxisTransitionType.horizontal,
                    child: child,
                  );
                },
                child: _visibleContent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLayout() {
    return Column(
      children: [
        AuthScreenLoginWidget(
          onLogin: (params) {
            _login(params);
          },
        ),
        const VSpace(5),
        _buildSocialLoginHeader(),
        const VSpace(5),
        _buildSocialLoginButtons(),
        const VSpace(10),
        _buildSignUpButton(),
      ],
    );
  }

  Widget _buildSignUpLayout() {
    return SignUpWidget(
      onSignUp: _signUp,
      onSignIn: _goToSignIn,
    );
  }

  Widget _buildSocialLoginHeader() {
    final theme = context.theme;
    final Widget divider = Expanded(
      child: Container(
        height: 2,
        color: theme.dividerColor,
      ),
    );
    return Row(
      children: [
        divider,
        Padding(
          padding: const EdgeInsets.all(15),
          child: Text(
            context.localizations.socialSignInLabel,
            style: theme.textTheme.bodySmall,
          ),
        ),
        divider,
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Observer(builder: (context) {
      return GoogleSignInButton(
        onTap: () {},
        loading: _signInStore.loading,
      );
    });
  }

  Widget _buildSignUpButton() {
    return TextButton(
      onPressed: _signInStore.loading ? null : _goToSignUp,
      style: TextButton.styleFrom(
        foregroundColor: context.theme.colorScheme.onSurface.withOpacity(0.8),
      ),
      child: Text(context.localizations.createAccountButtonText),
    );
  }

  void _login(AuthProviderParams params) {
    _signInStore.login(params);
  }

  void _signUp(SignUpParams params) {
    _signUpStore.signUp(params);
  }

  void _goToSignUp() {
    setState(() {
      _contentType = _AuthScreenContentType.signUp;
    });
  }

  void _goToSignIn() {
    setState(() {
      _contentType = _AuthScreenContentType.signIn;
    });
  }

  void handleAuthResult(AsyncResult4<KUser> result) {
    final localizations = context.localizations;
    result.whenOrNull(
      success: (user) {
        _toHome();
      },
      error: (e, s) {
        String message;
        switch (e.runtimeType) {
          case InvalidAuthEmailException:
            message = localizations.authErrorInvalidEmail;
            break;
          case InvalidAuthPasswordException:
            message = localizations.authErrorInvalidPassword;
            break;
          case AccountNotFoundException:
            message = localizations.authErrorAccountNotFound;
            break;
          case AccountAlreadyExistsException:
            message = localizations.authErrorAccountAlreadyExists;
            break;
          default:
            message = localizations.authError;
            break;
        }
        context.showErrorSnackBar(message);
      },
    );
  }

  Future<void> _toHome() async {
    await removeAuthScreenScope();
    if (mounted) {
      AppNavigator.home(context);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:kanban/auth/auth_manager.dart';
import 'package:kanban/di/di_config.dart';
import 'package:kanban/nav/navigator.dart';
import 'package:kanban/utils/after_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with AfterLayoutMixin {
  late final AuthManager _authManager;

  @override
  void initState() {
    super.initState();
    _authManager = getIt();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (_authManager.isLoggedIn) {
      AppNavigator.home(context);
      return;
    }
    AppNavigator.auth(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Material();
  }
}

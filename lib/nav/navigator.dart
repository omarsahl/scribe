import 'package:flutter/material.dart';
import 'package:kanban/core/logger/logger.dart';
import 'package:kanban/ui/auth/auth_screen.dart';
import 'package:kanban/ui/board/board_screen.dart';
import 'package:kanban/ui/board/completed_tasks_screen.dart';
import 'package:kanban/ui/home/home_screen.dart';
import 'package:kanban/ui/splash/splash_screen.dart';
import 'package:kanban/ui/task/new_task_screen.dart';
import 'package:kanban/ui/task/task_screen.dart';

@immutable
abstract class IRoute<I, O> {
  const IRoute();

  abstract final String path;

  Widget build(BuildContext context, I args);

  I parseInputArgs(Object? args) => args as I;

  @protected
  Route<O> buildRoute(RouteSettings settings, I args) =>
      MaterialPageRoute<O>(builder: (context) => build(context, args), settings: settings);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is IRoute && runtimeType == other.runtimeType && path == other.path;

  @override
  int get hashCode => path.hashCode;
}

class SplashScreenRoute extends IRoute {
  const SplashScreenRoute();

  @override
  final String path = '/';

  @override
  Widget build(BuildContext context, args) => const SplashScreen();
}

class AuthScreenRoute extends IRoute {
  const AuthScreenRoute();

  @override
  final String path = 'auth';

  @override
  Widget build(BuildContext context, args) => const AuthScreen();
}

class HomeScreenRoute extends IRoute {
  const HomeScreenRoute();

  @override
  final String path = 'home';

  @override
  Widget build(BuildContext context, args) => const HomeScreen();
}

class BoardScreenRoute extends IRoute<String, void> {
  const BoardScreenRoute();

  @override
  final String path = 'board';

  @override
  Widget build(BuildContext context, args) => BoardScreen(args);
}

class NewTaskScreenRoute extends IRoute<NewTaskScreenInputArgs, void> {
  const NewTaskScreenRoute();

  @override
  final String path = 'newTask';

  @override
  Widget build(BuildContext context, args) => NewTaskScreen(args);
}

class TaskScreenRoute extends IRoute<TaskScreenInputArgs, void> {
  const TaskScreenRoute();

  @override
  final String path = 'task';

  @override
  Widget build(BuildContext context, args) => TaskScreen(args);
}

class CompletedTasksScreenRoute extends IRoute<String, void> {
  const CompletedTasksScreenRoute();

  @override
  final String path = 'board/history';

  @override
  Widget build(BuildContext context, args) => CompletedTasksScreen(args);
}

class AppNavigator {
  AppNavigator._();

  static final Map<String, IRoute> _routesPathsMap = _initRoutesMap();
  static final Set<IRoute> _allRoutes = {
    const SplashScreenRoute(),
    const AuthScreenRoute(),
    const HomeScreenRoute(),
    const BoardScreenRoute(),
    const CompletedTasksScreenRoute(),
    const TaskScreenRoute(),
    const NewTaskScreenRoute(),
  };

  static String get initialRoute => const SplashScreenRoute().path;

  static RouteFactory get routeFactory {
    return (settings) {
      final IRoute? route = _routesPathsMap[settings.name];
      if (route == null) throw 'Invalid route path ${settings.name}';
      dynamic args;
      try {
        args = route.parseInputArgs(settings.arguments);
      } catch (e, s) {
        logger.e("Error parsing route args", e, s);
        rethrow;
      }
      return route.buildRoute(settings, args);
    };
  }

  static Future<O?> push<I extends Object?, O extends Object?>(
    BuildContext context,
    IRoute<I, O> route, {
    I? args,
  }) {
    return Navigator.pushNamed<O?>(context, route.path, arguments: args);
  }

  static Future<void> auth(BuildContext context) {
    return Navigator.pushNamedAndRemoveUntil(context, const AuthScreenRoute().path, (route) => false);
  }

  static Future<void> home(BuildContext context) {
    return Navigator.pushNamedAndRemoveUntil(context, const HomeScreenRoute().path, (route) => false);
  }

  static Future<O?> pushInRoot<I extends Object?, O extends Object?>(
    BuildContext context,
    IRoute<I, O> route, {
    I? args,
  }) {
    return Navigator.of(context, rootNavigator: true).pushNamed<O?>(route.path, arguments: args);
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    return Navigator.pop<T>(context, result);
  }

  static Map<String, IRoute> _initRoutesMap() {
    Map<String, IRoute> result = {};
    for (final e in _allRoutes) {
      result[e.path] = e;
    }
    return result;
  }
}

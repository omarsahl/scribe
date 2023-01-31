import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kanban/di/di_config.dart';
import 'package:kanban/firebase/firebase_initializer.dart';
import 'package:kanban/nav/navigator.dart';
import 'package:kanban/style/themes.dart';
import 'package:kanban/ui/settings/settings_store.dart';
import 'package:kanban/utils/context_ext.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.instance.initialize();
  await configureDependencies();
  runApp(const ScribeApp());
}

class ScribeApp extends StatefulWidget {
  const ScribeApp({super.key});

  @override
  State<ScribeApp> createState() => _ScribeAppState();
}

class _ScribeAppState extends State<ScribeApp> {
  late final SettingsStore _store;

  @override
  void initState() {
    super.initState();
    _store = getIt();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _store.isDarkTheme ? darkColorTheme : lightColorTheme,
        onGenerateTitle: (context) => context.localizations.appName,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [
          Locale('en'),
        ],
        initialRoute: AppNavigator.initialRoute,
        onGenerateRoute: AppNavigator.routeFactory,
      );
    });
  }
}

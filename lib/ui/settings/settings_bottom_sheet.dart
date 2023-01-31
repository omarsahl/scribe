import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kanban/di/di_config.dart';
import 'package:kanban/di/scopes/home_screen_scope.dart';
import 'package:kanban/nav/navigator.dart';
import 'package:kanban/style/shapes.dart';
import 'package:kanban/ui/settings/settings_store.dart';
import 'package:kanban/ui/widgets/space.dart';
import 'package:kanban/utils/context_ext.dart';

Future showSettingsBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    clipBehavior: Clip.hardEdge,
    shape: Shapes.bottomSheetShape20,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return const SettingsBottomSheet();
    },
  );
}

class SettingsBottomSheet extends StatefulWidget {
  const SettingsBottomSheet({Key? key}) : super(key: key);

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  late final SettingsStore _store;

  @override
  void initState() {
    super.initState();
    _store = getIt();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localizations = context.localizations;
    return Material(
      type: MaterialType.card,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              localizations.settings,
              style: theme.textTheme.titleLarge,
            ),
            const VSpace(20),
            Observer(
              builder: (context) {
                return SwitchListTile(
                  value: _store.isDarkTheme,
                  onChanged: (_) => _store.toggleTheme(),
                  title: Text(localizations.darkThemeSwitch),
                );
              },
            ),
            const VSpace(25),
            FilledButton(
              onPressed: _logOut,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
              child: Text(localizations.logOut),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logOut() async {
    _store.logOut();
    AppNavigator.pop(context);
    await removeHomeScreenScope();
    if (mounted) {
      AppNavigator.auth(context);
    }
  }
}

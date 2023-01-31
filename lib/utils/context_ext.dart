import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;

extension ContextExt on BuildContext {
  AppLocalizations get localizations => AppLocalizations.of(this)!;

  Locale get locale => Localizations.localeOf(this);

  TextDirection get directionality => Directionality.of(this);

  bool get isRtl => directionality == TextDirection.rtl;

  ThemeData get theme => Theme.of(this);

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => mediaQuery.size;

  TextDirection textDirectionForLanguage([String? language]) {
    if (language == null) {
      return directionality;
    }
    return intl.Bidi.isRtlLanguage(language) ? TextDirection.rtl : TextDirection.ltr;
  }
}

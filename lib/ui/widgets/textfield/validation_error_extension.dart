import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kanban/ui/widgets/textfield/text_field_state.dart';

extension TextFieldValidationErrorX on TextFieldValidationError? {
  String? getLocalizedMessage(
    AppLocalizations localization,
    String fieldName, [
    int? minLength,
    int? maxLength,
  ]) {
    switch (this) {
      case TextFieldValidationError.empty:
        return localization.emptyTextErrorMessage(fieldName);
      case TextFieldValidationError.blank:
        return localization.blankTextErrorMessage(fieldName);
      case TextFieldValidationError.invalidLength:
        return localization.invalidLengthTextErrorMessage(fieldName, minLength!, maxLength!);
      case TextFieldValidationError.invalidFormat:
        return localization.invalidTextErrorMessage(fieldName);
      case null:
        return null;
    }
  }
}

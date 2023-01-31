import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'text_field_state.g.dart';

TextFieldValidationError? noOpValidator(String text) => null;

TextFieldValidationError? notBlankValidator(String text) {
  if (text.trim().isEmpty) {
    return TextFieldValidationError.blank;
  }
  return null;
}

enum TextFieldValidationError {
  /// An empty 0-length text.
  empty,

  /// A text that contains only whitespace characters.
  blank,

  /// A text that doesn't have the required length of characters.
  invalidLength,

  /// A text that's not in the required valid format.
  /// For example, a text that doesn't match a specific [RegExp].
  invalidFormat
}

/// Signature of callbacks that takes a string [text] and checks whether it's valid or not.
/// For a string that is 'valid', null should be returned. If the string is 'invalid', a non-null
/// [TextFieldValidationError] should be returned instead.
/// The returned [TextFieldValidationError] describes why [text] is invalid.
typedef TextFieldValidator = TextFieldValidationError? Function(String text);

/// Used to encapsulate the validation [errorType] returned by [TextFieldValidator]s and the 'invalid' [text]
/// that resulted in that [errorType].
class TextFieldValidatorResult {
  TextFieldValidatorResult(this.errorType, this.text);

  final TextFieldValidationError errorType;
  final String text;
}

/// A MobX store that encapsulate the state of a [TextField].
/// It basically manages the error, enable/disable states for a text field.
class TextFieldStateStore = _TextFieldStateStore with _$TextFieldStateStore;

abstract class _TextFieldStateStore with Store {
  _TextFieldStateStore({
    String initialText = '',
    bool isEnabled = false,
    TextFieldValidator? validator,
  })  : _text = initialText,
        _isEnabled = isEnabled,
        _validator = validator;

  final TextFieldValidator? _validator;

  @readonly
  String _text;

  @readonly
  TextFieldValidatorResult? _error;

  @readonly
  bool _isEnabled;

  @computed
  bool get isValid => _validator == null || _validator!(_text) == null;

  @action
  void setText(String text) {
    _text = text;
    final errorType = _validator?.call(text);
    _error = errorType == null ? null : TextFieldValidatorResult(errorType, text);
  }

  @action
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }
}

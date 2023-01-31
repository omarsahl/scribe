import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kanban/style/borders.dart';
import 'package:kanban/ui/widgets/textfield/text_field_state.dart';
import 'package:kanban/ui/widgets/textfield/validation_error_extension.dart';
import 'package:kanban/utils/context_ext.dart';

class KTextField extends StatelessWidget {
  const KTextField({
    required this.hint,
    required this.state,
    this.fieldName,
    this.style,
    this.controller,
    this.maxLines = 1,
    this.minLines,
    this.minCharacters = 1,
    this.maxCharacters = -1,
    this.expands = false,
    this.showCounter = false,
    this.keyboardType,
    this.textAlignVertical,
    this.textAlign = TextAlign.start,
    super.key,
  });

  final TextFieldStateStore state;
  final TextEditingController? controller;
  final TextStyle? style;
  final String hint;
  final String? fieldName;
  final bool expands;
  final int? maxLines;
  final int? minLines;
  final int minCharacters;
  final int maxCharacters;
  final bool showCounter;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;

  @override
  Widget build(BuildContext context) {
    return _buildTextFiled(context.localizations);
  }

  Widget _buildTextFiled(AppLocalizations localizations) {
    return Observer(
      builder: (context) {
        return TextField(
          style: style,
          expands: expands,
          maxLines: maxLines,
          minLines: minLines,
          controller: controller,
          keyboardType: keyboardType,
          textAlign: textAlign,
          textAlignVertical: textAlignVertical,
          onChanged: controller == null ? state.setText : null,
          decoration: InputDecoration(
            filled: true,
            hintText: hint,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: Borders.roundedAll5,
            ),
            errorText: state.error?.errorType.getLocalizedMessage(
              localizations,
              fieldName ?? hint,
              minCharacters,
              maxCharacters,
            ),
            contentPadding: const EdgeInsets.all(10),
            counterText: showCounter ? '${state.text.length}/$maxCharacters' : null,
          ),
        );
      },
    );
  }
}

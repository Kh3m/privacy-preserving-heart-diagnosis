import 'package:flutter/material.dart';
import '../../../constant.dart';

/// One form field: a dropdown for a category, or a number box for a
/// measurement. Either way it saves the training-data code as text.
class PatientInfoField extends StatelessWidget {
  final String field;
  final Map fieldValue;
  final String actualValue;
  final Function onSave;

  const PatientInfoField({
    super.key,
    required this.field,
    required this.onSave,
    required this.fieldValue,
    required this.actualValue,
  });

  InputDecoration _decoration() {
    final unit = fieldValue['unit'];
    return InputDecoration(
      labelText: unit == null ? fieldValue['label'] : '${fieldValue['label']} ($unit)',
      labelStyle: const TextStyle(color: mTitleTextColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: fieldValue['options'] == null ? _numberField() : _dropdown(),
    );
  }

  Widget _dropdown() {
    final options = fieldValue['options'] as Map<String, int>;
    // A saved value from an older version of the form may not be a valid
    // option any more, so start empty instead of crashing.
    final saved = int.tryParse(actualValue);
    return DropdownButtonFormField<int>(
      initialValue: options.containsValue(saved) ? saved : null,
      isExpanded: true,
      decoration: _decoration(),
      items: [
        for (final option in options.entries)
          DropdownMenuItem(value: option.value, child: Text(option.key)),
      ],
      onChanged: (_) {},
      validator: (value) => value == null ? 'Please choose an option' : null,
      onSaved: (value) => onSave(field, value.toString()),
    );
  }

  Widget _numberField() {
    final decimal = fieldValue['decimal'] == true;
    final num min = fieldValue['min'];
    final num max = fieldValue['max'];
    return TextFormField(
      initialValue: actualValue,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      decoration: _decoration(),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return 'Please enter a value';
        final number = decimal ? double.tryParse(text) : int.tryParse(text);
        if (number == null) {
          return decimal ? 'Please enter a number' : 'Please enter a whole number';
        }
        if (number < min || number > max) return 'Must be between $min and $max';
        return null;
      },
      onSaved: (value) => onSave(field, value!.trim()),
    );
  }
}

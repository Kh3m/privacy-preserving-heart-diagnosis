import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/models/patient/cardiology.dart';

/// The form must produce exactly the codes the deployed model was trained on.
void main() {
  final model = json.decode(File(
          '../he_services/ml_models/heart_disease_logistic_regression.json')
      .readAsStringSync());
  final features = (model['features'] as List).cast<Map>();
  final fields = Cardiolgy.getFieldsDesc();

  test('form has the same 13 fields as the model', () {
    final modelColumns = {for (final f in features) f['column']};
    expect(fields.keys.toSet(), modelColumns);
  });

  test('every model category is a choice in the form, and nothing more', () {
    for (final entry in fields.entries) {
      final options = entry.value['options'] as Map<String, int>?;
      final modelCodes = {
        for (final f in features)
          if (f['column'] == entry.key && f['equals'] != null) f['equals']
      };
      if (options == null) {
        expect(modelCodes, isEmpty, reason: '${entry.key} should be a category');
      } else if (modelCodes.isEmpty) {
        // Yes/no fields go to the model as a plain 0 or 1, not one-hot.
        expect(options.values.toSet(), {0, 1}, reason: entry.key);
      } else {
        expect(options.values.toSet(), modelCodes, reason: entry.key);
      }
    }
  });

  test('measurements have a label, unit and range', () {
    for (final entry in fields.entries) {
      if (entry.value['options'] != null) continue;
      expect(entry.value['label'], isNotNull, reason: entry.key);
      expect(entry.value['unit'], isNotNull, reason: entry.key);
      expect(entry.value['min'] < entry.value['max'], isTrue, reason: entry.key);
    }
  });
}

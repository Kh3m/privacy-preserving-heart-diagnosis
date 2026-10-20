import 'package:flutter/material.dart';

class Cardiolgy with ChangeNotifier {
  final int age;
  final int sex;
  final int cp;
  final int trestbps;
  final int chol;
  final int fbs;
  final int restecg;
  final int thalach;
  final int exang;
  final double oldpeak;
  final int slope;
  final int ca;
  final int thal;

  Cardiolgy({
    required this.age,
    required this.sex,
    required this.cp,
    required this.trestbps,
    required this.chol,
    required this.fbs,
    required this.restecg,
    required this.thalach,
    required this.exang,
    required this.oldpeak,
    required this.slope,
    required this.ca,
    required this.thal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'age': age,
      'sex': sex,
      'cp': cp,
      'trestbps': trestbps,
      'chol': chol,
      'fbs': fbs,
      'restecg': restecg,
      'thalach': thalach,
      'exang': exang,
      'oldpeak': oldpeak,
      'slope': slope,
      'ca': ca,
      'thal': thal,
    };
  }

  // Future<void> insertCardiology(data) {

  // }

  /// The 13 form fields, in the order the model expects.
  ///
  /// Measurements have a unit and an allowed range. Category fields have
  /// plain-English options mapped to the codes used in the training data
  /// (heart_disease_model/data/heart-disease.csv). That CSV is the Kaggle copy
  /// of the UCI Cleveland data, which renumbered several categories, so these
  /// codes were checked row by row against the original UCI file.
  static Map<String, dynamic> getFieldsDesc() {
    return {
      'age': {
        'label': 'Age',
        'unit': 'years',
        'min': 1,
        'max': 120,
      },
      'sex': {
        'label': 'Sex',
        'options': {'Female': 0, 'Male': 1},
      },
      'cp': {
        'label': 'Chest pain type',
        'options': {
          'Typical angina': 3,
          'Atypical angina': 1,
          'Non-anginal pain': 2,
          'No chest pain (asymptomatic)': 0,
        },
      },
      'trestbps': {
        'label': 'Resting blood pressure',
        'unit': 'mm Hg',
        'min': 50,
        'max': 250,
      },
      'chol': {
        'label': 'Cholesterol',
        'unit': 'mg/dl',
        'min': 50,
        'max': 700,
      },
      'fbs': {
        'label': 'Fasting blood sugar above 120 mg/dl',
        'options': {'No': 0, 'Yes': 1},
      },
      'restecg': {
        'label': 'Resting ECG result',
        'options': {
          'Normal': 1,
          'ST-T wave abnormality': 2,
          'Left ventricular hypertrophy': 0,
        },
      },
      'thalach': {
        'label': 'Maximum heart rate during exercise',
        'unit': 'beats per minute',
        'min': 40,
        'max': 250,
      },
      'exang': {
        'label': 'Chest pain caused by exercise',
        'options': {'No': 0, 'Yes': 1},
      },
      'oldpeak': {
        'label': 'ST depression after exercise',
        'unit': 'mm',
        'min': 0,
        'max': 10,
        'decimal': true,
      },
      'slope': {
        'label': 'Slope of the ST segment during exercise',
        'options': {'Upsloping': 2, 'Flat': 1, 'Downsloping': 0},
      },
      'ca': {
        'label': 'Major vessels seen on fluoroscopy',
        'options': {'0': 0, '1': 1, '2': 2, '3': 3, 'Unknown': 4},
      },
      'thal': {
        'label': 'Thallium stress test result',
        'options': {
          'Normal': 2,
          'Fixed defect': 1,
          'Reversible defect': 3,
          'Unknown': 0,
        },
      },
    };
  }

  @override
  String toString() {
    return '{ age: $age, sex: $sex, cp: $cp, trestbps: $trestbps, chol: $chol, fbs: $fbs, restecg: $restecg, thalach: $thalach, exang: $exang, oldpeak: $oldpeak, slope: $slope, ca: $ca, thal: $thal}';
  }
}

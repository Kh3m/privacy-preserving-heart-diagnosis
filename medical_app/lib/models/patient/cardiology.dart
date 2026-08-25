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

  static Map<String, dynamic> getFieldsDesc() {
    return {
      'age': {
        'desc': 'age in years',
      },
      'sex': {
        'desc': 'sex (1 = male; 0 = female)',
        'possible_values': [0, 1],
      },
      'cp': {
        'desc':
            'chest pain type (1: typical angina 2: atypical angina 3: non-anginal pain 4: asymptomatic)',
        'possible_values': [1, 2, 3, 4],
      },
      'trestbps': {
        'desc': 'resting blood pressure (in mm Hg on admission to hospital)',
      },
      'chol': {
        'desc': 'serum cholesetoral in mg/d1',
      },
      'fbs': {
        'desc': '(fasting blood sugar > 120 mg/d1) (1 = true; 0 = false)',
        'possible_values': [0, 1],
      },
      'restecg': {
        'desc':
            'resting electrocardiographic results (0: normal 1: having ST-T wave abnormality 2: showing probable criteria',
        'possible_values': [0, 1, 2],
      },
      // 'restecg': {
      //   'desc':
      //       'resting electrocardiographic results (0: normal 1: having ST-T wave abnormality (T wave inversions and/or ST elevation or depression of > 0.05 mV) 2: showing probable or definite left ventricular hypertrophy by Estes\' criteria',
      //   'possible_values': [0, 1, 2],
      // },
      'thalach': {
        'desc': 'maximum heart rate achieved',
      },
      'exang': {
        'desc': 'exercise induced angina (1 = yes; 0 = no)',
        'possible_values': [0, 1],
      },
      'oldpeak': {
        'desc': 'ST depression induced by exercise relative to rest',
      },
      'slope': {
        'desc':
            'the slope of the peak exercise ST segment (0: upsloping 1: flatsloping 2: downslopins',
        'possible_values': [0, 1, 2],
      },
      'ca': {
        'desc': 'number of major vessels (0-3) colored by flourosopy',
        'possible_values': [0, 1, 2, 3],
      },
      'thal': {
        'desc': '1,3: normal; 6: fixed defect; 7: reversable defect',
        'possible_values': [1, 2, 3, 6, 7],
      },
    };
  }

  @override
  String toString() {
    return '{ age: $age, sex: $sex, cp: $cp, trestbps: $trestbps, chol: $chol, fbs: $fbs, restecg: $restecg, thalach: $thalach, exang: $exang, oldpeak: $oldpeak, slope: $slope, ca: $ca, thal: $thal}';
  }
}

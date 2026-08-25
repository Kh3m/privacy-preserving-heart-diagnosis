import 'package:medical_app/models/sqflite_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../cardiology.dart';

class CardiologySQFlite {
  static Future<void> insertCardiology(Cardiolgy cardiolgy) async {
    final db = await SQFliteHelper.database();
    await db.insert(
      SQFliteHelper.cardiologyTable,
      cardiolgy.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Cardiolgy>> cardiologies() async {
    final db = await SQFliteHelper.database();

    final List<Map<String, dynamic>> maps = await db.query(
      SQFliteHelper.cardiologyTable,
    );

    return List.generate(maps.length, (i) {
      return Cardiolgy(
        // maps[i]['id'],
        age: maps[i]['age'],
        sex: maps[i]['sex'],
        cp: maps[i]['cp'],
        trestbps: maps[i]['trestbps'],
        chol: maps[i]['chol'],
        fbs: maps[i]['fbs'],
        restecg: maps[i]['restecg'],
        thalach: maps[i]['thalach'],
        exang: maps[i]['exang'],
        oldpeak: maps[i]['oldpeak'],
        slope: maps[i]['slope'],
        ca: maps[i]['ca'],
        thal: maps[i]['thal'],
      );
    });
  }

  // return List.generate(maps.length, (i) {
  //     return Cardiolgy(
  //       // maps[i]['id'],
  //       age: int.parse(maps[i]['age']),
  //       sex: int.parse(maps[i]['sex']),
  //       cp: int.parse(maps[i]['cp']),
  //       trestbps: int.parse(maps[i]['trestbps']),
  //       chol: int.parse(maps[i]['chol']),
  //       fbs: int.parse(maps[i]['fbs']),
  //       restecg: int.parse(maps[i]['restecg']),
  //       thalach: int.parse(maps[i]['thalach']),
  //       exang: int.parse(maps[i]['exang']),
  //       oldpeak: double.parse(maps[i]['oldpeak']),
  //       slope: int.parse(maps[i]['slope']),
  //       ca: int.parse(maps[i]['ca']),
  //       thal: int.parse(maps[i]['thal']),
  //     );
  //   });
}

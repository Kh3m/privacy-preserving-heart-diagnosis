import 'dart:developer';

import 'package:medical_app/models/patient/key_m.dart';
import 'package:medical_app/models/sqflite_helper.dart';
import 'package:sqflite/sqflite.dart';

class KeySQFlite {
  static Future<void> insertKey(KeyM key) async {
    final db = await SQFliteHelper.database();
    await db.insert(
      SQFliteHelper.keyTable,
      key.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteKeys() async {
    final db = await SQFliteHelper.database();
    await db.delete(SQFliteHelper.keyTable);
  }

  static Future<List<KeyM>> keys() async {
    final db = await SQFliteHelper.database();
    final List<Map<String, dynamic>> keyList =
        await db.query(SQFliteHelper.keyTable);
    // log(keyList.toString());
    return List.generate(keyList.length, (i) {
      return KeyM(
        // id: keyList[i]['id'],
        n: keyList[i]['n'],
        p: keyList[i]['p'],
        q: keyList[i]['q'],
      );
    });
  }
}

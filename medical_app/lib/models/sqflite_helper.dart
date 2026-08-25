import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQFliteHelper {
  static String cardiologyTable = "cardiology";
  static String keyTable = "key";

  static Future<Database> database() async {
    final database = openDatabase(
      join(await getDatabasesPath(), "medical.db"),
      onCreate: ((db, version) async {
        await createTables(db);
      }),
      onUpgrade: (db, oldVersion, newVersion) async {
        await createTables(db);
      },
      version: 1,
    );
    return database;
  }

  static Future<void> createTables(Database db) async {
    await db.execute("""
      CREATE TABLE $cardiologyTable(
      id INTEGER PRIMARY KEY,
      age int,
      sex int,
      cp int,
      trestbps int,
      chol  int,
      fbs  int,
      restecg int,
      thalach  int,
      exang  int,
      oldpeak  double,
      slope  int,
      ca  int,
      thal  int,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    """);

    await db.execute("""
      CREATE TABLE $keyTable(
      id INTEGER PRIMARY KEY,
      n TEXT,
      p TEXT,
      q TEXT,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    """);
  }
}

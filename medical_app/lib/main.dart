
import 'package:flutter/material.dart';
import 'package:medical_app/models/patient/enc_dec.dart';
import 'package:provider/provider.dart';

// import './screens/home/home_screen_.dart';
import './screens/home/home_screen.dart';
import 'models/patient/patient.dart';
import './models/sqflite_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Delete Keys
  // KeySQFlite.deleteKeys();
  SQFliteHelper.database();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: EncDec()),
        ChangeNotifierProvider.value(value: Patient())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Doctor Appointment App',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          // primarySwatch: Colors.deepPurple,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

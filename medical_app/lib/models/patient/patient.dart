import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medical_app/models/patient/key_m.dart';

import '../url.dart';

class Patient with ChangeNotifier {

  Map<String, dynamic> _encData = {};

  Future<Map<String, dynamic>> get encData async => _encData;

  Future<void> sendForHeartDiseaseDiag(data) async {
    final url = Uri.parse('${URL.baseUrl}/${URL.classificationUrl}');
    final res = await http.post(
      url,
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    final resDec = json.decode(res.body);

    _encData = resDec;

    notifyListeners();
  }

  
  Future<List> decryptHeartDiseaseTarget(data) async {
    final url = Uri.parse('${URL.baseUrl}/${URL.decryptHeartDiseaseTargetUrl}');
    final res = await http.post(
      url,
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    return json.decode(res.body);
  }
}

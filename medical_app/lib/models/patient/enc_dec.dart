import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medical_app/models/patient/key_m.dart';

import '../url.dart';

class EncDec with ChangeNotifier {
  Map<String, dynamic> _encData = {};

  Map<String, dynamic> get encData => _encData;

  Future<void> sendForEnc(data) async {
    final url = Uri.parse('${URL.baseUrl}/${URL.encUrl}');
    final res = await http.post(
      url,
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    _encData = json.decode(res.body);
    notifyListeners();
  }

  Future<KeyM> generateKeyPair() async {
    final url = Uri.parse('${URL.baseUrl}/${URL.genKeyPairUrl}');
    final res = await http.get(url, headers: {
      'Content-Type': 'application/json',
    });

    return KeyM.fromJson(json.decode(res.body));
  }
}

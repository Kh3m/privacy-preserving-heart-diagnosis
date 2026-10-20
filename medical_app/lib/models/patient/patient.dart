import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medical_app/crypto/paillier.dart';
import 'package:medical_app/models/patient/key_m.dart';

import '../url.dart';

class Patient with ChangeNotifier {

  Map<String, dynamic> _encData = {};

  Future<Map<String, dynamic>> get encData async => _encData;

  /// Sends only the public key and ciphertexts; the server returns the
  /// encrypted model score.
  Future<void> sendForHeartDiseaseDiag(data) async {
    final url = Uri.parse('${URL.baseUrl}/${URL.classificationUrl}');
    final res = await http.post(
      url,
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode != 200) {
      throw Exception('Classification failed (${res.statusCode}): ${res.body}');
    }
    final resDec = json.decode(res.body);

    _encData = resDec;

    notifyListeners();
  }

  /// Decrypts the score on the device. A positive score means the model
  /// predicts heart disease (probability above 0.5).
  Future<List> decryptHeartDiseaseTarget(List values, KeyM key) async {
    final keys = PaillierKeyPair.fromStrings(key.n, key.p, key.q);
    final score = keys.privateKey.decrypt(EncryptedNumber.fromJson(values[0]));
    return [score > 0 ? 1.0 : 0.0];
  }
}

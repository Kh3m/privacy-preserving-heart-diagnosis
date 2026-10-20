import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:medical_app/crypto/paillier.dart';
import 'package:medical_app/models/patient/key_m.dart';

import '../url.dart';

/// Key generation and encryption, both on the device.
///
/// Neither the private key nor the plaintext features are sent anywhere.
/// The heavy BigInt work runs in a background isolate to keep the UI smooth.
class EncDec with ChangeNotifier {
  Map<String, dynamic> _encData = {};

  Map<String, dynamic> get encData => _encData;

  /// Encrypts the form [values] (field name -> text) under [key].
  Future<void> sendForEnc(Map values, KeyM key) async {
    final features = await _fetchFeatures();
    final x = [
      for (final f in features)
        f['equals'] == null
            ? double.parse(values[f['column']].toString())
            : (double.parse(values[f['column']].toString()) == f['equals'] ? 1.0 : 0.0)
    ];

    final encrypted = await compute(_encrypt, {'n': key.n, 'values': x});
    _encData = {
      'public_key': {'n': key.n},
      'features': [
        for (final f in features)
          f['equals'] == null ? f['column'] : '${f['column']} = ${f['equals']}'
      ],
      'values': encrypted,
    };
    notifyListeners();
  }

  Future<KeyM> generateKeyPair() async {
    final keys = await compute(_generateKeyPair, 2048);
    return KeyM(n: keys[0], p: keys[1], q: keys[2]);
  }

  /// The one-hot layout the server's model expects, in order.
  Future<List> _fetchFeatures() async {
    final url = Uri.parse('${URL.baseUrl}/${URL.classificationUrl}');
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Could not load model features (${res.statusCode})');
    }
    return json.decode(res.body)['features'];
  }
}

List<String> _generateKeyPair(int bits) {
  final keys = generateKeyPair(bits: bits);
  return [
    keys.publicKey.n.toString(),
    keys.privateKey.p.toString(),
    keys.privateKey.q.toString(),
  ];
}

List<List<dynamic>> _encrypt(Map<String, dynamic> args) {
  final publicKey = PaillierPublicKey(BigInt.parse(args['n']));
  return [
    for (final v in args['values'] as List<double>) publicKey.encrypt(v).toJson()
  ];
}

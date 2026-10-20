import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/crypto/paillier.dart';

void main() {
  // 1024-bit keys keep the suite fast; the arithmetic is the same at 2048.
  final keys = generateKeyPair(bits: 1024);
  final pub = keys.publicKey;
  final priv = keys.privateKey;

  test('generates a modulus of the requested length', () {
    expect(pub.n.bitLength, 1024);
    expect(priv.p * priv.q, pub.n);
  });

  test('round-trips positive, negative, zero and decimal values', () {
    for (final v in [0.0, 1.0, 63.0, 233.0, 2.3, -1.5, -0.000123]) {
      expect(priv.decrypt(pub.encrypt(v)), closeTo(v, 1e-9));
    }
  });

  test('encryption is randomized', () {
    expect(pub.encrypt(1.0).ciphertext, isNot(pub.encrypt(1.0).ciphertext));
  });

  test('ciphertexts add homomorphically', () {
    final a = pub.encrypt(2.5), b = pub.encrypt(-4.0);
    final sum = EncryptedNumber(a.ciphertext * b.ciphertext % pub.nsquare, a.exponent);
    expect(priv.decrypt(sum), closeTo(-1.5, 1e-9));
  });

  test('ciphertexts multiply by a plaintext integer', () {
    final a = pub.encrypt(-3.25);
    final scaled = EncryptedNumber(a.ciphertext.modPow(BigInt.from(7), pub.nsquare), a.exponent);
    expect(priv.decrypt(scaled), closeTo(-22.75, 1e-9));
  });

  test('restores a keypair from stored strings', () {
    final restored = PaillierKeyPair.fromStrings(
        pub.n.toString(), priv.p.toString(), priv.q.toString());
    expect(restored.privateKey.decrypt(pub.encrypt(42.0)), closeTo(42.0, 1e-9));
  });

  test('rejects mismatched p and q', () {
    expect(() => PaillierPrivateKey(pub, priv.p, priv.p), throwsArgumentError);
  });

  test('serializes as [ciphertext, exponent]', () {
    final c = pub.encrypt(7.0);
    final back = EncryptedNumber.fromJson(c.toJson());
    expect(back.ciphertext, c.ciphertext);
    expect(back.exponent, defaultExponent);
  });
}

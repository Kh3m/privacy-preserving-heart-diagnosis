import 'dart:math';

/// Paillier encryption, run entirely on the device.
///
/// Compatible with python-paillier (`phe`), which the server uses: g = n + 1,
/// and a real number is encoded as `mantissa * 16^exponent` with the mantissa
/// taken mod n, so negative numbers wrap around to the top of the range.
///
/// The private key (p, q) never leaves the device. The server receives only
/// n and ciphertexts.

/// Fixed-point precision for encrypted values: 16^-8 is about 2.3e-10.
const int defaultExponent = -8;

final BigInt _two = BigInt.two;
final BigInt _one = BigInt.one;

class EncryptedNumber {
  final BigInt ciphertext;
  final int exponent;

  EncryptedNumber(this.ciphertext, this.exponent);

  /// The `[ciphertext, exponent]` pair the API sends and receives.
  List<dynamic> toJson() => [ciphertext.toString(), exponent];

  factory EncryptedNumber.fromJson(List<dynamic> json) =>
      EncryptedNumber(BigInt.parse(json[0].toString()), json[1] as int);
}

class PaillierPublicKey {
  final BigInt n;
  final BigInt nsquare;

  /// Mantissas above this (and below n - maxInt) are overflow, as in phe.
  final BigInt maxInt;

  PaillierPublicKey(this.n)
      : nsquare = n * n,
        maxInt = n ~/ BigInt.from(3);

  EncryptedNumber encrypt(double value,
      {int exponent = defaultExponent, Random? random}) {
    final m = encode(value, exponent);
    final r = _randomBelow(n, random ?? Random.secure());
    final c = ((n * m + _one) % nsquare) * r.modPow(n, nsquare) % nsquare;
    return EncryptedNumber(c, exponent);
  }

  BigInt encode(double value, int exponent) {
    final mantissa = BigInt.from((value * pow(16, -exponent)).round());
    if (mantissa.abs() > maxInt) {
      throw ArgumentError('$value is too large to encode');
    }
    return mantissa % n;
  }

  double decode(BigInt mantissa, int exponent) {
    if (mantissa >= n - maxInt) {
      mantissa -= n;
    } else if (mantissa > maxInt) {
      throw StateError('Overflow: the encrypted value is out of range');
    }
    return mantissa.toDouble() * pow(16, exponent);
  }
}

class PaillierPrivateKey {
  final PaillierPublicKey publicKey;
  final BigInt p;
  final BigInt q;
  final BigInt _lambda;
  final BigInt _mu;

  PaillierPrivateKey._(this.publicKey, this.p, this.q, this._lambda, this._mu);

  factory PaillierPrivateKey(PaillierPublicKey publicKey, BigInt p, BigInt q) {
    if (p * q != publicKey.n) {
      throw ArgumentError('p * q does not match the public key');
    }
    // With g = n + 1, mu = lambda^-1 mod n.
    final lambda = (p - _one) * (q - _one);
    return PaillierPrivateKey._(
        publicKey, p, q, lambda, lambda.modInverse(publicKey.n));
  }

  double decrypt(EncryptedNumber x) {
    final n = publicKey.n;
    final u = x.ciphertext.modPow(_lambda, publicKey.nsquare);
    final m = ((u - _one) ~/ n) * _mu % n;
    return publicKey.decode(m, x.exponent);
  }
}

class PaillierKeyPair {
  final PaillierPublicKey publicKey;
  final PaillierPrivateKey privateKey;

  PaillierKeyPair(this.publicKey, this.privateKey);

  static PaillierKeyPair fromStrings(String n, String p, String q) {
    final publicKey = PaillierPublicKey(BigInt.parse(n));
    return PaillierKeyPair(
      publicKey,
      PaillierPrivateKey(publicKey, BigInt.parse(p), BigInt.parse(q)),
    );
  }
}

/// Generates a keypair whose modulus n is exactly [bits] long.
PaillierKeyPair generateKeyPair({int bits = 2048, Random? random}) {
  random ??= Random.secure();
  while (true) {
    final p = _randomPrime(bits ~/ 2, random);
    final q = _randomPrime(bits ~/ 2, random);
    if (p == q) continue;
    final publicKey = PaillierPublicKey(p * q);
    if (publicKey.n.bitLength != bits) continue;
    return PaillierKeyPair(publicKey, PaillierPrivateKey(publicKey, p, q));
  }
}

final List<int> _smallPrimes = () {
  const limit = 2000;
  final composite = List<bool>.filled(limit, false);
  final primes = <int>[];
  for (var i = 2; i < limit; i++) {
    if (composite[i]) continue;
    primes.add(i);
    for (var j = i * i; j < limit; j += i) {
      composite[j] = true;
    }
  }
  return primes;
}();

BigInt _randomBits(int bits, Random random) {
  var result = BigInt.zero;
  for (var i = 0; i < bits; i += 32) {
    result = (result << 32) | BigInt.from(random.nextInt(1 << 32));
  }
  return result >> (((bits + 31) ~/ 32) * 32 - bits);
}

/// Uniform in [1, n).
BigInt _randomBelow(BigInt n, Random random) {
  while (true) {
    final r = _randomBits(n.bitLength, random);
    if (r > BigInt.zero && r < n) return r;
  }
}

BigInt _randomPrime(int bits, Random random) {
  while (true) {
    // Setting the top two bits makes the product of two such primes 2 * bits long.
    final candidate = _randomBits(bits, random) |
        (_one << (bits - 1)) |
        (_one << (bits - 2)) |
        _one;
    if (_isProbablePrime(candidate, random)) return candidate;
  }
}

bool _isProbablePrime(BigInt n, Random random, {int rounds = 40}) {
  for (final p in _smallPrimes) {
    final bp = BigInt.from(p);
    if (n == bp) return true;
    if (n % bp == BigInt.zero) return false;
  }

  // Miller-Rabin: write n - 1 = d * 2^s with d odd.
  final nMinusOne = n - _one;
  var d = nMinusOne;
  var s = 0;
  while (d.isEven) {
    d >>= 1;
    s++;
  }

  for (var i = 0; i < rounds; i++) {
    final a = _randomBelow(n - _two - _one, random) + _one; // [2, n - 2]
    var x = a.modPow(d, n);
    if (x == _one || x == nMinusOne) continue;
    var witness = true;
    for (var r = 1; r < s; r++) {
      x = x.modPow(_two, n);
      if (x == nMinusOne) {
        witness = false;
        break;
      }
    }
    if (witness) return false;
  }
  return true;
}

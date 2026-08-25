class KeyM {
  final String n;
  final String p;
  final String q;

  KeyM({
    required this.n,
    required this.p,
    required this.q,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'n': n,
      'p': p,
      'q': q,
    };
  }

  factory KeyM.fromJson(Map<dynamic, dynamic> json) {
    return KeyM(
      n: json['public_key']['n'],
      p: json['private_key']['p'],
      q: json['private_key']['q'],
    );
  }

  @override
  String toString() {
    return '{public_key: {n: $n}, private_key: {p: $p, q: $q} }';
  }
}

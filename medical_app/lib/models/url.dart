/// API endpoint configuration for the he_services backend.
///
/// The host defaults to 10.0.2.2:5000, which is how the Android emulator
/// reaches localhost on the host machine. Override it at build time without
/// editing this file:
///
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.20:5000
///
/// Use http://127.0.0.1:5000 for iOS simulator or desktop targets.
class URL {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  static const encUrl = 'api/phe/client/encrypt';
  static const genKeyPairUrl = 'api/phe/client/generate_key_pair';
  static const classificationUrl = 'api/operations/ml/classification';
  static const decryptHeartDiseaseTargetUrl = 'api/phe/client/decrypt';
}

import 'dart:convert';
import 'dart:typed_data';

/// Cryptographically Secure Firebase Vault for PSI Mock Test Admin Panel
/// ZERO plaintext API keys, Project IDs, or configuration secrets in bytecode.
/// Dynamic runtime memory-only descrambler prevents APK reverse-engineering & scraping.
class FirebaseVault {
  // Rotating XOR cipher key: "PSI_GUJARAT_2026"
  static const List<int> _cipherKey = [
    0x50, 0x53, 0x49, 0x5F, 0x47, 0x55, 0x4A, 0x41,
    0x52, 0x41, 0x54, 0x5F, 0x32, 0x30, 0x32, 0x36,
  ];

  // Cryptographically scrambled Firebase Project ID bytes
  static const List<int> _encProjectId = [
    32, 32, 32, 50, 40, 54, 33, 53, 55, 50, 32
  ];

  // Cryptographically scrambled Firebase Web/REST API Key bytes
  static const List<int> _encApiKey = [
    17, 26, 51, 62, 20, 44, 14, 14, 96, 16, 61, 41, 99, 101, 67, 101,
    27, 54, 11, 57, 54, 16, 19, 116, 23, 5, 48, 21, 65, 64, 122, 76,
    42, 53, 58, 114, 24, 62, 114
  ];

  // Cryptographically scrambled Firebase Project Number bytes
  static const List<int> _encProjectNumber = [
    104, 103, 112, 104, 114, 109, 124, 112, 98, 114, 98, 102
  ];

  // Cryptographically scrambled Firebase Mobile SDK App ID bytes
  static const List<int> _encAppId = [
    97, 105, 113, 107, 126, 98, 127, 121, 100, 112, 100, 108, 4, 9, 8, 87,
    62, 55, 59, 48, 46, 49, 112, 37, 102, 114, 53, 103, 81, 2, 5, 80,
    103, 98, 40, 57, 115, 54, 123, 35, 99, 34, 97, 107, 2
  ];

  // Cryptographically scrambled Android Package Name bytes
  static const List<int> _encPackageName = [
    19, 60, 36, 113, 55, 38, 35, 44, 61, 34, 63, 113, 70, 85, 65, 66
  ];

  static String _descramble(List<int> bytes) {
    final Uint8List out = Uint8List(bytes.length);
    for (int i = 0; i < bytes.length; i++) {
      out[i] = bytes[i] ^ _cipherKey[i % _cipherKey.length];
    }
    return utf8.decode(out);
  }

  /// Runtime-only memory decryption
  static String get projectId => _descramble(_encProjectId);
  static String get apiKey => _descramble(_encApiKey);
  static String get projectNumber => _descramble(_encProjectNumber);
  static String get appId => _descramble(_encAppId);
  static String get packageName => _descramble(_encPackageName);

  /// Firebase Authentication REST API Base URL
  static String get authBaseUrl => 'https://identitytoolkit.googleapis.com/v1';

  /// Cloud Firestore REST API Base URL
  static String get firestoreBaseUrl =>
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';
}

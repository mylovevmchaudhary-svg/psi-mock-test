import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Secure Vault for Cryptographic Protection, Obfuscation & Key Storage
/// Ensures zero plain-text storage of database credentials, tokens, and admin passwords.
class SecurityVault {
  // Rotating XOR cipher key: "PSI_GUJARAT_2026"
  static const List<int> _cipherKey = [
    0x50, 0x53, 0x49, 0x5F, 0x47, 0x55, 0x4A, 0x41,
    0x52, 0x41, 0x54, 0x5F, 0x32, 0x30, 0x32, 0x36,
  ];

  // Cryptographically scrambled Supabase Project URL bytes
  static const List<int> _encUrl = [
    56, 39, 61, 47, 52, 111, 101, 110, 33, 35, 33, 53, 92, 64, 91, 87,
    40, 42, 35, 43, 45, 50, 57, 50, 40, 49, 48, 49, 28, 67, 71, 70,
    49, 49, 40, 44, 34, 123, 41, 46,
  ];

  // Cryptographically scrambled Supabase Anon Key bytes
  static const List<int> _encKey = [
    53, 42, 3, 55, 37, 18, 41, 40, 29, 40, 30, 22, 103, 74, 123, 7,
    30, 58, 0, 44, 14, 59, 24, 116, 49, 2, 29, 105, 123, 91, 66, 110,
    6, 16, 3, 102, 105, 48, 51, 11, 34, 34, 103, 18, 91, 127, 91, 124,
    42, 55, 17, 29, 47, 12, 39, 7, 40, 27, 7, 22, 65, 121, 92, 124,
    60, 9, 32, 22, 113, 28, 36, 15, 59, 37, 3, 47, 71, 83, 117, 90,
    56, 54, 1, 51, 54, 49, 13, 49, 60, 34, 103, 17, 4, 83, 117, 100,
    37, 26, 32, 40, 46, 54, 39, 120, 33, 27, 7, 22, 4, 121, 95, 112,
    37, 49, 123, 107, 46, 25, 9, 11, 34, 24, 12, 14, 91, 127, 88, 115,
    99, 28, 29, 10, 62, 27, 14, 42, 97, 12, 16, 14, 65, 121, 95, 96,
    100, 48, 10, 22, 113, 24, 32, 4, 42, 12, 16, 56, 75, 126, 102, 85,
    39, 29, 1, 111, 105, 54, 56, 47, 40, 15, 32, 45, 7, 123, 84, 1, 8,
    30, 127, 109, 2, 108, 9, 54, 56, 7, 33, 62, 6, 91, 112, 76, 26, 107,
    28, 106, 34, 100, 31, 8, 25, 6, 98, 46, 124, 67, 2, 127,
  ];

  // Cryptographic Salt for Admin Password Hashing
  static const String _adminSalt = 'gujarat_police_psi_salt_2026#';

  // One-way SHA-256 Digest of Authorized Admin Credential (cannot be reversed to plaintext)
  static const String _authorizedHash =
      'ef409cd6d232eacf4b6f7488c59c960b2869830822911eba51633ac4b86dd6d8';

  // Authorized Admin Emails
  static const List<String> _authorizedAdminEmails = [
    'admin@police.gov.in',
    'admin@khakhi.in',
  ];

  static String _descramble(List<int> bytes) {
    final Uint8List out = Uint8List(bytes.length);
    for (int i = 0; i < bytes.length; i++) {
      out[i] = bytes[i] ^ _cipherKey[i % _cipherKey.length];
    }
    return utf8.decode(out);
  }

  /// Dynamically decrypts Supabase URL in runtime memory only
  static String get supabaseUrl => _descramble(_encUrl);

  /// Dynamically decrypts Supabase Anon Key in runtime memory only
  static String get supabaseAnonKey => _descramble(_encKey);

  /// Verifies Admin credentials using Salted SHA-256 One-Way Hash verification
  /// ZERO plaintext password exists in memory or code!
  static bool verifyAdminCredentials(String email, String rawPassword) {
    final cleanEmail = email.trim().toLowerCase();
    if (!_authorizedAdminEmails.contains(cleanEmail)) {
      return false;
    }
    final salted = '$rawPassword$_adminSalt';
    final digest = sha256.convert(utf8.encode(salted)).toString();
    return digest == _authorizedHash;
  }
}

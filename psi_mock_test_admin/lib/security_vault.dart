import 'firebase_vault.dart';

/// Legacy SecurityVault proxy re-routed to cryptographically secure FirebaseVault.
/// Pure Firebase Cloud infrastructure.
class SecurityVault {
  static String get projectId => FirebaseVault.projectId;
  static String get apiKey => FirebaseVault.apiKey;
  static String get packageName => FirebaseVault.packageName;
}

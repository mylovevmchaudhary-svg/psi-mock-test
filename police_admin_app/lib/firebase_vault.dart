class FirebaseVault {
  static const String projectId = 'psimocktest';
  static const String apiKey = 'AIzaSyDO2QivQUqSKeBfqEY5EDdJspHzzfs-_k8';
  static const String projectNumber = '849758610369';
  static const String appId = '1:849758610369:android:d43a8c27f71af4c1b1c540';
  static const String packageName = 'Com.psimock.test';

  static String get firestoreBaseUrl =>
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';
}

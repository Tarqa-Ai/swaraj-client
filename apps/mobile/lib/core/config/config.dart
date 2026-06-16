
class SwarajConfig {
  // Override at build time: flutter run --dart-define=API_URL=http://10.0.2.2:4000/api
  static String get apiBaseUrl {
    const String envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) return envUrl;
    return 'https://swaraj-backend-dkgn.onrender.com/api';
  }
}

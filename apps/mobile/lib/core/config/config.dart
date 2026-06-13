
class SwarajConfig {
  static String get apiBaseUrl {
    const String envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) return envUrl;
    return 'https://swaraj-backend-dkgn.onrender.com/api';
  }
}

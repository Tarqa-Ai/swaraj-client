
class SwarajConfig {
  static String get apiBaseUrl {
    const String envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) return envUrl;
    // Production backend on Render
    return 'https://swaraj-backend-dkgn.onrender.com/api';
  }
}

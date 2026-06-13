
class SwarajConfig {
  static String get apiBaseUrl {
    const String envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isEmpty) {
      return 'http://10.0.2.2:4000/api';
    }
    return envUrl;
  }
}


class SwarajConfig {
  static String get apiBaseUrl {
    const String envUrl = String.fromEnvironment('API_URL');
    return envUrl;
  }
}

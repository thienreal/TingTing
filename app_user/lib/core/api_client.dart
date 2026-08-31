// Change to your machine's LAN IP if running on physical device
const String baseUrl = 'http://10.0.2.2:3000'; // Default for Android emulator

class ApiClient {
  static String getBaseUrl() {
    return baseUrl;
  }
}

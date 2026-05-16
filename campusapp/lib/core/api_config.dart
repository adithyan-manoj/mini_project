import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  /// Easily change this IP when you switch networks!
  /// Examples:
  /// - "10.0.2.2" (Android Emulator)
  /// - "192.168.1.x" (Home Wi-Fi - replace x with your Mac's IP)
  /// - "10.141.4.152" (College Wi-Fi)
  static const String networkIp = "10.0.2.2";
  static const String port = "8000";

  /// The centralized Backend URL used by all services.
  static String get baseUrl {
    // If you define backend_url in your .env file, it will use that first.
    // Otherwise, it falls back to the networkIp defined above.
    final envUrl = dotenv.env['backend_url'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    return "http://$networkIp:$port";
  }
}

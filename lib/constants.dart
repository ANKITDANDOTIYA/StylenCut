class AppConstants {
  // Update this single IP address when your local host machine's IP changes
  static const String ipAddress = '192.168.1.12';
  static const String port = '5000';
  
  // Base URLs
  static const String backendUrl = 'http://$ipAddress:$port';
  static const String authBaseUrl = '$backendUrl/api/auth';
  static const String salonBaseUrl = '$backendUrl/api/salons';
}

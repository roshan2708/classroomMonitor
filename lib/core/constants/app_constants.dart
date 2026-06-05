class AppConstants {
  static const String appName = 'Smart Classroom Monitor';
  static const String appSubtitle = 'Real-Time IoT Classroom Analytics';
  
  // ThingSpeak API Config
  static const String channelId = '3401297';
  static const String lastFeedUrl = 'https://api.thingspeak.com/channels/$channelId/feeds/last.json';
  static const String historyFeedsUrl = 'https://api.thingspeak.com/channels/$channelId/feeds.json';
  
  // Settings & Storage Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyDemoMode = 'demo_mode';
  
  // Monitoring Limits & Rules
  static const int refreshIntervalSeconds = 15;
  static const double temperatureThresholdWarning = 35.0;
  
  // Status Labels
  static const String tempStatusNormal = 'Normal';
  static const String tempStatusWarning = 'Warning';
  static const String humidityStatusNormal = 'Normal';
  static const String humidityStatusHigh = 'High';
  
  static const String lightStatusBright = 'Bright';
  static const String lightStatusModerate = 'Moderate';
  static const String lightStatusDark = 'Dark';
}

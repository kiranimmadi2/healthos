class AppConstants {
  AppConstants._();

  static const String appName = 'HealthOS';
  static const String healthIdPrefix = 'HOS';
  static const int healthIdLength = 12;
  static const String healthIdPattern = r'^HOS-\d{4}-[A-Z0-9]{4}$';

  static const int otpLength = 6;
  static const int otpExpirySeconds = 300;

  static const int maxRecentReports = 5;
  static const int maxRecentVisits = 10;
  static const int maxSymptomHistoryItems = 50;

  static const int paginationLimit = 20;
  static const int searchDebounceMs = 300;

  static const double biomarkerChartMinHeight = 200.0;
  static const double biomarkerChartMaxHeight = 400.0;
}

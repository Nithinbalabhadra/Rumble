enum DataMode { local, remote }

class AppConfig {
  static const String dataModeValue =
      String.fromEnvironment('DATA_MODE', defaultValue: 'local');

  static DataMode get dataMode =>
      dataModeValue.toLowerCase() == 'remote' ? DataMode.remote : DataMode.local;

  /// App branding constants
  static const String appName = 'Joker Junction';
  static const String appTagline = 'Your circle. Your rules. Your table.';
  static const String appVersion = '1.0.0';
}

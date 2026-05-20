enum DataMode { local, remote }

class AppConfig {
  static const String dataModeValue =
      String.fromEnvironment('DATA_MODE', defaultValue: 'local');

  static DataMode get dataMode =>
      dataModeValue.toLowerCase() == 'remote' ? DataMode.remote : DataMode.local;
}

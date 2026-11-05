/// Backend location, in one place.
///
/// Defaults to the deployed Render backend. To point a build somewhere
/// else (for example a local server) without editing code:
///
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://surplus-served-backend.onrender.com',
  );

  static const String apiUrl = '$baseUrl/api';
}

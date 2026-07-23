class Config {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://complaintiq-backend-ciaw.onrender.com',
  );
}

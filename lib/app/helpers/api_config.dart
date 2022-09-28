class ApiConfig {
  ApiConfig._();
  static final ApiConfig _instance = ApiConfig._();
  factory ApiConfig() => _instance;
  static const String apiKey = 'ed9885670748417a84878d19f34ef35c';
  static const String baseUrl =
      'https://newsapi.org/v2/top-headlines?country=id&category=health';
  static const String pageSize = '&pageSize=';
  static const String page = '&page=';
  static const String qApiKey = '&apiKey=';

  // https://newsapi.org/v2/top-headlines?country=id&category=health&pagSize=14&page=2&apiKey=ed9885670748417a84878d19f34ef35c
}

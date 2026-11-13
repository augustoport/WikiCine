enum Environment {
  production(
    baseUrl: 'https://api.themoviedb.org/3',
    mediaUrl: 'https://media.themoviedb.org/t/p/w400',
    signupUrl: 'https://www.themoviedb.org/signup',
    token: String.fromEnvironment('TOKEN'),
    apiKey: String.fromEnvironment('API_KEY'),
  );

  final String baseUrl;
  final String mediaUrl;
  final String signupUrl;
  final String token;
  final String apiKey;

  const Environment({
    required this.baseUrl,
    required this.mediaUrl,
    required this.signupUrl,
    required this.token,
    required this.apiKey,
  });
}

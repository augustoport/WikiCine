import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// PNG transparente de 1x1 devolvido para qualquer requisição de imagem.
final _transparentPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

/// Substitui o `HttpClient` usado por `Image.network`.
///
/// O `flutter test` responde 400 a toda requisição HTTP, e várias telas usam
/// `Image.network` sem `errorBuilder` (ex.: `ProfileHeader`, `DrawerWidget`),
/// o que faria os testes falharem por erro de carregamento de imagem.
/// Chame `HttpOverrides.global = FakeImageHttpOverrides()` no `setUpAll`.
class FakeImageHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

class _FakeHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _FakeRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeRequest implements HttpClientRequest {
  @override
  HttpHeaders get headers => _FakeHeaders();

  @override
  Future<HttpClientResponse> close() async => _FakeResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _transparentPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_transparentPng).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

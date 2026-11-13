import 'package:cinerating/domain/usecases/tv_show/get_tv_show_crew_usecase.dart';
import 'package:cinerating/domain/usecases/tv_show/get_tv_show_details_usecase.dart';
import 'package:cinerating/domain/usecases/tv_show/get_tv_shows_usecase.dart';
import 'package:cinerating/domain/usecases/tv_show/search_tv_shows_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeTvRepository repository;

  setUp(() => repository = FakeTvRepository());

  group('GetTvShowsUseCase', () {
    test('retorna a lista de séries do repositório', () async {
      final shows = await GetTvShowsUseCase(repository)();

      expect(shows, Fixtures.tvShows);
      expect(repository.calls, ['getTvShows']);
    });

    test('propaga falha do repositório', () {
      repository.failing.add('getTvShows');

      expect(GetTvShowsUseCase(repository).call, throwsA(isA<FakeRepositoryException>()));
    });
  });

  group('SearchTvShowsUseCase', () {
    test('repassa o termo de busca e retorna o resultado', () async {
      final result = await SearchTvShowsUseCase(repository)('dark');

      expect(result, [Fixtures.tvB]);
      expect(repository.calls, ['searchTvShows:dark']);
    });

    test('propaga falha do repositório', () {
      repository.failing.add('searchTvShows');

      expect(
        () => SearchTvShowsUseCase(repository)('x'),
        throwsA(isA<FakeRepositoryException>()),
      );
    });
  });

  group('GetTvShowDetailsUseCase', () {
    test('busca os detalhes pelo id', () async {
      final show = await GetTvShowDetailsUseCase(repository)('10');

      expect(show, same(Fixtures.tvA));
      expect(repository.calls, ['getTvShowDetails:10']);
    });

    test('propaga falha do repositório', () {
      repository.failing.add('getTvShowDetails');

      expect(
        () => GetTvShowDetailsUseCase(repository)('10'),
        throwsA(isA<FakeRepositoryException>()),
      );
    });
  });

  group('GetTvShowCrewUseCase', () {
    test('retorna os créditos do repositório sem filtrar', () async {
      final credits = await GetTvShowCrewUseCase(repository)('10');

      expect(credits, same(repository.credits));
      expect(repository.calls, ['getTvShowCredits:10']);
    });

    test('propaga falha do repositório', () {
      repository.failing.add('getTvShowCredits');

      expect(
        () => GetTvShowCrewUseCase(repository)('10'),
        throwsA(isA<FakeRepositoryException>()),
      );
    });
  });
}

import '../../domain/entities/credits.dart';
import '../../domain/entities/tv_show.dart';
import '../../domain/repositories/tv_repository.dart';
import '../datasources/data/tv_data.dart';

class TvRepositoryImpl implements TvRepository {
  final TvData remoteDataSource;

  TvRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TvShow>> getTvShows() => remoteDataSource.getTvShows();

  @override
  Future<List<TvShow>> searchTvShows(String query) =>
      remoteDataSource.searchTvShows(query);

  @override
  Future<TvShow> getTvShowDetails(String tvShowId) =>
      remoteDataSource.getTvShowDetails(tvShowId);

  @override
  Future<Credits> getTvShowCredits(String tvShowId) =>
      remoteDataSource.getTvShowCredits(tvShowId);
}

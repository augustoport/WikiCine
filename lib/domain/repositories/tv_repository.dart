import '../entities/credits.dart';
import '../entities/tv_show.dart';

abstract class TvRepository {
  Future<List<TvShow>> getTvShows();
  Future<List<TvShow>> searchTvShows(String query);
  Future<TvShow> getTvShowDetails(String tvShowId);
  Future<Credits> getTvShowCredits(String tvShowId);
}

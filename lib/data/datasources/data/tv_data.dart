import '../../../domain/entities/credits.dart';
import '../../../domain/entities/tv_show.dart';

abstract class TvData {
  Future<List<TvShow>> getTvShows();
  Future<List<TvShow>> searchTvShows(String query);
  Future<TvShow> getTvShowDetails(String tvShowId);
  Future<Credits> getTvShowCredits(String tvShowId);
}

import '../../entities/tv_show.dart';
import '../../repositories/tv_repository.dart';

class SearchTvShowsUseCase {
  final TvRepository tvRepository;

  SearchTvShowsUseCase(this.tvRepository);

  Future<List<TvShow>> call(String query) {
    return tvRepository.searchTvShows(query);
  }
}

import '../../entities/tv_show.dart';
import '../../repositories/tv_repository.dart';

class GetTvShowsUseCase {
  final TvRepository tvRepository;

  GetTvShowsUseCase(this.tvRepository);

  Future<List<TvShow>> call() {
    return tvRepository.getTvShows();
  }
}

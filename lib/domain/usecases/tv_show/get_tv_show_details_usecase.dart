import '../../entities/tv_show.dart';
import '../../repositories/tv_repository.dart';

class GetTvShowDetailsUseCase {
  final TvRepository tvRepository;

  GetTvShowDetailsUseCase(this.tvRepository);

  Future<TvShow> call(String tvShowId) {
    return tvRepository.getTvShowDetails(tvShowId);
  }
}

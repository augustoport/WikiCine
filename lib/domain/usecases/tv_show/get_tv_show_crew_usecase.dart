import '../../entities/credits.dart';
import '../../repositories/tv_repository.dart';

class GetTvShowCrewUseCase {
  final TvRepository tvRepository;

  GetTvShowCrewUseCase(this.tvRepository);

  Future<Credits> call(String tvShowId) {
    return tvRepository.getTvShowCredits(tvShowId);
  }
}

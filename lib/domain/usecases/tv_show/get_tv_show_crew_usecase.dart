import '../../repositories/tv_repository.dart';

class GetTvShowCrewUseCase {
  final TvRepository tvRepository;

  GetTvShowCrewUseCase(this.tvRepository);

  Future<dynamic> call(String tvShowId) {
    return tvRepository.getTvShowCrew(tvShowId);
  }
}

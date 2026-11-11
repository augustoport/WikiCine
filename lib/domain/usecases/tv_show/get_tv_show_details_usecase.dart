import '../../repositories/tv_repository.dart';

class GetTvShowDetailsUseCase {
  final TvRepository tvRepository;

  GetTvShowDetailsUseCase(this.tvRepository);

  Future<dynamic> call(String tvShowId) {
    return tvRepository.getTvShowDetailsFull(tvShowId);
  }
}

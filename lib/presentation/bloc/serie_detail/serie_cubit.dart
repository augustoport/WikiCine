import 'package:bloc/bloc.dart';

import '../../../core/locator.dart';
import '../../../data/models/tv_crew_model.dart';
import '../../../data/models/tv_show_model.dart';
import '../../../domain/usecases/tv_show/get_tv_show_crew_usecase.dart';
import '../../../domain/usecases/tv_show/get_tv_show_details_usecase.dart';

part 'serie_state.dart';

class SerieCubit extends Cubit<SerieState> {
  SerieCubit() : super(SerieInitial());
  final _getTvShowDetailsUseCase = getIt<GetTvShowDetailsUseCase>();
  final _getTvShowCrewUseCase = getIt<GetTvShowCrewUseCase>();

  Future<void> getSerieDetail(String serieId) async {
    emit(SerieLoading());
    try {
      final serie = await _getTvShowDetailsUseCase(serieId);
      final cast = await _getTvShowCrewUseCase(serieId);
      final serieModel = TvShowModel.fromMap(serie);
      final castModel = TvShowCrew.fromMap(cast);
      emit(SerieSuccess(serieModel, castModel.cast ?? []));
    } catch (e) {
      emit(SerieError());
    }
    return;
  }
}

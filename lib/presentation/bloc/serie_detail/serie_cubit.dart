import 'package:bloc/bloc.dart';

import '../../../domain/entities/credits.dart';
import '../../../domain/entities/tv_show.dart';
import '../../../domain/usecases/tv_show/get_tv_show_crew_usecase.dart';
import '../../../domain/usecases/tv_show/get_tv_show_details_usecase.dart';

part 'serie_state.dart';

class SerieCubit extends Cubit<SerieState> {
  SerieCubit({
    required GetTvShowDetailsUseCase getTvShowDetailsUseCase,
    required GetTvShowCrewUseCase getTvShowCrewUseCase,
  }) : _getTvShowDetailsUseCase = getTvShowDetailsUseCase,
       _getTvShowCrewUseCase = getTvShowCrewUseCase,
       super(SerieInitial());

  final GetTvShowDetailsUseCase _getTvShowDetailsUseCase;
  final GetTvShowCrewUseCase _getTvShowCrewUseCase;

  Future<void> getSerieDetail(String serieId) async {
    emit(SerieLoading());
    try {
      final serie = await _getTvShowDetailsUseCase(serieId);
      final credits = await _getTvShowCrewUseCase(serieId);
      emit(SerieSuccess(serie, credits.cast));
    } catch (e) {
      emit(SerieError());
    }
  }
}

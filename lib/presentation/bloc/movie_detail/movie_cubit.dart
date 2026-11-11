import 'package:bloc/bloc.dart';
import 'package:cinerating/domain/entities/movie.dart';

import '../../../core/locator.dart';
import '../../../data/models/crew_model.dart';
import '../../../data/models/movie_detail_model.dart';
import '../../../domain/usecases/movies/get_movie_crew_usecase.dart';
import '../../../domain/usecases/movies/get_movie_details_usecase.dart';

part 'movie_states.dart';

class MovieCubit extends Cubit<MovieStates> {
  MovieCubit() : super(MovieInitial());
  final _getMovieDetailsUseCase = getIt<GetMovieDetailsUseCase>();
  final _getMovieCrewUseCase = getIt<GetMovieCrewUseCase>();

  void filterCrew(List<CrewModel> crew, MovieDetailModel movieDetail) {
    final cast = crew.where((c) => c.knownForDepartment == "Acting").toList();
    final director = crew.firstWhere(
      (c) => c.job == "Director",
      orElse: () => CrewModel(name: "N/A", job: "Director"),
    );
    emit(MovieSuccess(movieDetail, cast, director));
  }

  Future<void> getMovieDetails(String movieId) async {
    emit(MovieLoading());
    try {
      final movieDetail = await _getMovieDetailsUseCase(movieId);
      final crew = await _getMovieCrewUseCase(movieId);
      final movieDetailModel = MovieDetailModel.fromMap(movieDetail);
      final crewList = (crew['cast'] as List)
          .map((c) => CrewModel.fromMap(c))
          .toList();
      filterCrew(crewList, movieDetailModel);
    } catch (e) {
      emit(MovieError());
    }
  }
}

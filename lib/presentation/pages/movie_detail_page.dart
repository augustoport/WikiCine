import 'package:cinerating/presentation/bloc/movie_detail/movie_cubit.dart';
import 'package:cinerating/presentation/widgets/content_detail.dart';
import 'package:cinerating/core/shared/themes/app_colors.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/locator.dart';

class MovieDetailPage extends StatefulWidget {
  final String movieId;
  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final movieCubit = getIt<MovieCubit>();
  final appColors = getIt<AppColors>();

  @override
  void initState() {
    Future.microtask(() {
      movieCubit.getMovieDetails(widget.movieId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder(
        bloc: movieCubit,
        builder: (context, state) {
          if (state is MovieLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is MovieSuccess) {
            return ContentDetail(
              content: state.movieDetail,
              type: "movie",
              cast: state.cast,
              director: state.director,
              isFavorite: state.isFavorite,
            );
          } else {
            return Center(
              child: Text(
                "Error",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            );
          }
        },
      ),
    );
  }
}

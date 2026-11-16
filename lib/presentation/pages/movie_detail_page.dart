import 'package:cinerating/presentation/bloc/movie_detail/movie_cubit.dart';
import 'package:cinerating/presentation/widgets/content_detail.dart';
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

  @override
  void initState() {
    Future.microtask(() {
      movieCubit.getMovieDetails(widget.movieId);
    });
    super.initState();
  }

  Future<void> _toggleFavorite() async {
    final result = await movieCubit.toggleFavorite();
    if (result == null || !mounted) return;

    final (message, color) = switch (result) {
      FavoriteResult.added => ('Adicionado com sucesso', Colors.green),
      FavoriteResult.removed => ('Removido com sucesso', Colors.green),
      FavoriteResult.addFailed => (
        'Não foi possível adicionar o filme aos favoritos',
        Colors.red,
      ),
      FavoriteResult.removeFailed => (
        'Não foi possível remover o filme dos favoritos',
        Colors.red,
      ),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
              showFavorite: state.canFavorite,
              favorite: movieCubit.isFavorite,
              onFavoriteTap: _toggleFavorite,
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

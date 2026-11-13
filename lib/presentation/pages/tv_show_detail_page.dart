// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cinerating/presentation/bloc/serie_detail/serie_cubit.dart';
import 'package:cinerating/presentation/widgets/content_detail.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/locator.dart';

class TvShowDetailPage extends StatefulWidget {
  final String id;
  const TvShowDetailPage({super.key, required this.id});

  @override
  State<TvShowDetailPage> createState() => _TvShowDetailPageState();
}

class _TvShowDetailPageState extends State<TvShowDetailPage> {
  final _tvCubit = getIt<SerieCubit>();

  @override
  void initState() {
    Future.microtask(() => _tvCubit.getSerieDetail(widget.id));
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
        bloc: _tvCubit,
        builder: (context, state) {
          if (state is SerieLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is SerieSuccess) {
            return ContentDetail(
              content: state.tvShow,
              type: 'tv',
              cast: state.cast,
            );
          } else if (state is SerieError) {
            return Text("Erro", style: TextStyle(color: Colors.white));
          } else {
            return Text("Erro");
          }
        },
      ),
    );
  }
}

import 'package:cinerating/data/models/crew_model.dart';
import 'package:cinerating/presentation/widgets/cast_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/shared/themes/app_colors.dart';

class ContentDetail extends StatelessWidget {
  final dynamic content;
  final dynamic cast;
  final dynamic director;
  final String type;
  const ContentDetail({
    super.key,
    required this.content,
    required this.type,
    this.cast,
    this.director,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) => Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor,
                  spreadRadius: .15,
                  blurRadius: .8,
                  offset: Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                SizedBox(
                  width: size.width,
                  child: Container(
                    height: size.height * .27,
                    width: size.width,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(4),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      child: Image.network(
                        content.backdropPath ?? "",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    height: size.height * .25,
                    width: size.width * .35,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.grey.shade400,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(6),
                      child: Image.network(
                        fit: BoxFit.cover,
                        content.posterPath ?? "",
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null &&
                                      loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      type == 'movie' ? content.title : content.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow, size: 18),
                        SizedBox(width: 5),
                        Text(
                          content.voteAverage?.toStringAsFixed(1) ?? "N/A",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(width: 5),
                        Text(
                          "(${content.voteCount?.toString() ?? "N/A"})",
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 5),
                        Text(
                          DateFormat("dd/MM/yyyy").format(
                            type == "movie"
                                ? content.releaseDate
                                : content.firstAirDate ?? DateTime.now(),
                          ),
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.white, size: 16),
                        SizedBox(width: 5),
                        Text(
                          "${type == 'movie' ? content.runtime?.toString() : '-'} min",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  "Genres:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(content.genres?.length ?? 0, (i) {
                      final genre = content.genres![i];
                      return Container(
                        margin: EdgeInsets.only(right: 5),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            genre.name ?? "N/A",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  content.overview ?? "N/A",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 10),
                if (type == "movie") ContentCreditWidget(cast, director),
                if (type == "tv") ContentCreditWidget(cast, director),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}

class ContentCreditWidget extends StatelessWidget {
  final dynamic cast;
  final dynamic director;
  const ContentCreditWidget(this.cast, this.director, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Cast:",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: .start,
            children: List.generate(cast.length, (i) {
              final actor = cast[i];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: CastCard(
                  actor,
                  roles: actor is CrewModel ? [] : actor.roles,
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 15),
        if (director != null && director.name != "N/A")
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: .end,
            children: [
              Text(
                "Directed by:",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 75,
                child: Column(
                  mainAxisAlignment: .start,
                  children: [
                    if (director.profilePath != null) ...[
                      Image.network(
                        director.profilePath ?? "",
                        height: 80,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ] else ...[
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.person, size: 50),
                      ),
                    ],
                    SizedBox(height: 5),
                    Text(
                      director.name ?? "N/A",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

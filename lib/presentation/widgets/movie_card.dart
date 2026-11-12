import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

class MovieCard extends StatelessWidget {
  final String? photo;
  final String? title;
  final String? vote;
  const MovieCard({super.key, this.photo, this.title, this.vote});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade800,
            spreadRadius: .1,
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade900, Colors.black],
          begin: AlignmentGeometry.topCenter,
          end: AlignmentGeometry.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          if (photo != null) ...[
            Container(
              height: size.height * .2,
              width: size.width * .23,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                ),
              ),
              child: CachedNetworkImage(
                imageUrl: photo!,
                imageBuilder: (context, provider) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        bottomLeft: Radius.circular(6),
                      ),
                      image: DecorationImage(
                        image: provider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
                placeholder: (context, url) {
                  return Center(child: ColoredBox(color: Colors.grey));
                },
                height: size.height * .2,
                fit: BoxFit.cover,
              ),
            ),
          ] else ...[
            Container(
              height: size.height * .2,
              width: size.width * .22,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(6)),
              ),
              child: Icon(Icons.camera_alt, color: Colors.white),
            ),
          ],

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title ?? "N/A",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    SizedBox(width: 5),
                    Text(
                      vote ?? "N/A",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

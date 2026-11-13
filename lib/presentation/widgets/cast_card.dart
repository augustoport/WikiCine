import 'package:material_ui/material_ui.dart';

import '../../domain/entities/credits.dart';

class CastCard extends StatelessWidget {
  final CastMember actor;
  const CastCard(this.actor, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .start,
      children: [
        if (actor.profilePath != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 100,
              width: 70,
              decoration: BoxDecoration(color: Colors.grey.shade400),
              child: Image.network(
                actor.profilePath!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loading) {
                  return loading == null
                      ? child
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        );
                },
              ),
            ),
          ),
        ] else ...[
          Container(
            height: 100,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.person, size: 50, color: Colors.grey.shade700),
          ),
        ],
        SizedBox(height: 10),
        SizedBox(
          width: 75,
          child: Column(
            children: [
              Text(
                actor.name ?? "N/A",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (actor.character != null)
                Text(
                  "as ${actor.character}",
                  style: TextStyle(color: Colors.white, fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

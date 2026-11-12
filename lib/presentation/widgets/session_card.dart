import 'package:material_ui/material_ui.dart';

class SessionCard extends StatelessWidget {
  final IconData icon;
  final String session;
  final Function() onTap;
  final bool active;
  const SessionCard({
    super.key,
    required this.icon,
    required this.session,
    required this.onTap,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: .center,
        children: [
          Icon(icon, color: active ? Colors.white : Colors.white.withAlpha(80)),
          Text(
            session,
            style: TextStyle(
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? Colors.white : Colors.white.withAlpha(80),
            ),
          ),
        ],
      ),
    );
  }
}

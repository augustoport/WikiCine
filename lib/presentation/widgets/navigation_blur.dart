import 'dart:ui';

import 'package:material_ui/material_ui.dart';

class NavigationBlur extends StatelessWidget {
  final Widget options;
  const NavigationBlur({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.grey.withAlpha(35)),
          child: options,
        ),
      ),
    );
  }
}

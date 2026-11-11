import 'package:flutter/material.dart';
import '../../core/locator.dart';
import '../../core/shared/themes/app_colors.dart';
import '../../domain/entities/user.dart';
import '../controllers/login_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = getIt<LoginController>();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(children: [ProfileHeader(user: controller.currentUser)]),
      
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final User? user;
  const ProfileHeader({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context);
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: size.padding.top + 20,
        bottom: 15,
      ),
      decoration: BoxDecoration(color: AppColors.primaryColor),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(50),
            child: Image.network(width: 100, user?.avatar?.tmdb ?? ""),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                user?.name ?? "",
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              Text(
                user?.username ?? "",
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

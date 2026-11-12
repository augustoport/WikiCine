import 'package:cinerating/presentation/pages/movie_detail_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/locator.dart';
import '../../core/shared/themes/app_colors.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/user.dart';
import '../bloc/profile/profile_cubit.dart';
import '../bloc/profile/profile_states.dart';
import '../controllers/login_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final controller = getIt<LoginController>();
  final bloc = getIt<ProfileCubit>();

  @override
  void initState() {
    bloc.initProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          ProfileHeader(user: controller.currentUser),
          BlocBuilder(
            bloc: bloc,
            builder: (BuildContext context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileSuccess) {
                return Favorites(favorites: state.favorites);
              } else {
                return const Center(
                  child: Text(
                    'Error loading profile',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
            },
          ),
        ],
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Row(
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
        ],
      ),
    );
  }
}

class Favorites extends StatelessWidget {
  final List<Movie> favorites;
  const Favorites({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Favorites', style: TextStyle(fontSize: 20, color: Colors.white)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: .start,
              children: List.generate(favorites.length, (i) {
                final fav = favorites[i];
                return InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MovieDetailPage(movieId: fav.id.toString()))),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    width: size.width * 0.3,
                    child: Column(
                      children: [
                        Image.network(
                          fav.posterPath ?? "",
                          fit: BoxFit.fill,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey,
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        Text(
                          fav.title ?? fav.name ?? "Title not available",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

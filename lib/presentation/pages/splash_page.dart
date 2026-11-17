import 'package:material_ui/material_ui.dart';

import '../../core/locator.dart';
import '../../core/shared/themes/app_colors.dart';
import '../../domain/entities/access_mode.dart';
import '../controllers/login_controller.dart';
import 'home_page.dart';
import 'login_page.dart';

/// Tela inicial: verifica a sessão salva e decide entre Home (conta ou
/// visitante) e Login, sem mostrar o login de passagem (spec 001, FR-017).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final loginController = getIt<LoginController>();

  @override
  void initState() {
    super.initState();
    // Adiado: checkExistingSession notifica listeners e não pode rodar
    // durante o build.
    Future.microtask(_route);
  }

  Future<void> _route() async {
    await loginController.checkExistingSession();
    if (!mounted) return;

    final Widget next = loginController.accessMode == AccessMode.none
        ? const LoginPage()
        : const HomePage();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

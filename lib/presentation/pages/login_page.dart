import 'package:cinerating/core/locator.dart';
import 'package:cinerating/core/shared/env.dart';
import 'package:cinerating/presentation/controllers/login_controller.dart';
import 'package:cinerating/presentation/pages/home_page.dart';
import 'package:cinerating/presentation/widgets/text_field_custom.dart';
import 'package:cinerating/core/shared/themes/app_colors.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginController = getIt<LoginController>();

  @override
  void initState() {
    super.initState();
    // Adiado: notifica listeners (ex.: DrawerWidget da rota anterior) e não
    // pode rodar durante o build.
    Future.microtask(loginController.checkExistingSession);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (loginController.emailController.text.isEmpty ||
        loginController.passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha todos os campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await loginController.login();

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuário/Senha incorreto(s)'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  Future<void> _openTmdbSignup() async {
    final Uri url = Uri.parse(Environment.production.signupUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          Image.asset('assets/img/logo.png'),
          TextFieldCustom(
            controller: loginController.emailController,
            hintText: 'Usuário',
            onChanged: (value) {},
          ),
          SizedBox(height: 30),
          TextFieldCustom(
            controller: loginController.passwordController,
            hintText: 'Senha',
            onChanged: (value) {},
            isPassword: true,
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Não possui conta no TMDB? ",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                InkWell(
                  onTap: _openTmdbSignup,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Clique aqui",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          InkWell(
            splashColor: Colors.transparent,
            onTap: loginController.isLoading ? null : _handleLogin,
            child: Container(
              width: size.width * 0.8,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 30,
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: loginController.isLoading
                    ? AppColors.primaryColor.withValues(alpha: 0.5)
                    : AppColors.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: loginController.isLoading
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Text(
                      "Login",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

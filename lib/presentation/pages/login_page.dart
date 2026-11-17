import 'package:cinerating/core/locator.dart';
import 'package:cinerating/core/shared/env.dart';
import 'package:cinerating/domain/entities/access_mode.dart';
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

    if (success && mounted) _goHome();
  }

  /// Vai para a Home descartando avisos de tentativas anteriores: o
  /// `ScaffoldMessenger` é do app inteiro e a SnackBar cobriria a Home.
  void _goHome() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  /// Modo visitante (spec 001): sessão de convidado do TMDB e Home.
  Future<void> _handleGuest() async {
    final success = await loginController.continueAsGuest();
    if (!mounted) return;

    if (success) {
      _goHome();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível entrar como visitante'),
          backgroundColor: Colors.red,
        ),
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
      // Rolável: com o teclado aberto o conteúdo não cabe e os botões ficariam
      // fora da área de toque. `minHeight` + `IntrinsicHeight` mantêm o
      // `Spacer` empurrando os botões para baixo quando há espaço.
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: ListenableBuilder(
                listenable: loginController,
                builder: (context, _) => _buildBody(context, size),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Size size) {
    final showGuest = loginController.accessMode != AccessMode.user;
    final bottomMargin = MediaQuery.of(context).padding.bottom + 30;
    return Column(
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
            margin: EdgeInsets.only(bottom: showGuest ? 12 : bottomMargin),
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
        if (showGuest)
          InkWell(
            splashColor: Colors.transparent,
            onTap: loginController.isLoading ? null : _handleGuest,
            child: Container(
              width: size.width * 0.8,
              margin: EdgeInsets.only(bottom: bottomMargin),
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryColor, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Continuar sem login",
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

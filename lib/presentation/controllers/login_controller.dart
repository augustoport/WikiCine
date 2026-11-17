import 'package:material_ui/material_ui.dart';

import '../../domain/entities/access_mode.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/get_access_mode_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/start_guest_session_usecase.dart';
import '../../domain/usecases/user/get_current_user_usecase.dart';

class LoginController extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool loadingDrawer = false;
  User? currentUser;

  /// Último modo de acesso conhecido (spec 001).
  AccessMode accessMode = AccessMode.none;

  /// Sem conta: visitante (sessão de convidado) ou ainda sem sessão. Considera
  /// [currentUser] porque o usuário pode estar em memória sem que
  /// [checkExistingSession] tenha rodado.
  bool get isGuest => currentUser == null && accessMode != AccessMode.user;

  LoginController({
    required LoginUseCase loginUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
    required StartGuestSessionUseCase startGuestSessionUseCase,
    required GetAccessModeUseCase getAccessModeUseCase,
  }) : _loginUseCase = loginUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _logoutUseCase = logoutUseCase,
       _startGuestSessionUseCase = startGuestSessionUseCase,
       _getAccessModeUseCase = getAccessModeUseCase;

  final LoginUseCase _loginUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;
  final StartGuestSessionUseCase _startGuestSessionUseCase;
  final GetAccessModeUseCase _getAccessModeUseCase;

  Future<bool> login() async {
    isLoading = true;
    notifyListeners();

    try {
      final user = await _loginUseCase(
        username: emailController.text,
        password: passwordController.text,
      );

      currentUser = user;
      accessMode = AccessMode.user;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Entra como visitante (sessão de convidado do TMDB). `false` se a sessão
  /// não pôde ser iniciada.
  Future<bool> continueAsGuest() async {
    isLoading = true;
    notifyListeners();

    try {
      await _startGuestSessionUseCase();
      accessMode = AccessMode.guest;
      currentUser = null;
      emailController.clear();
      passwordController.clear();
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Lê o modo de acesso salvo; só com sessão de conta busca o usuário.
  Future<void> checkExistingSession() async {
    try {
      loadingDrawer = true;
      notifyListeners();

      accessMode = await _getAccessModeUseCase();
      if (accessMode == AccessMode.user) {
        final user = await _getCurrentUserUseCase();
        if (user != null) currentUser = user;
      }
    } finally {
      loadingDrawer = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _logoutUseCase();
    currentUser = null;
    accessMode = AccessMode.none;
    emailController.clear();
    passwordController.clear();
    notifyListeners();
  }
}

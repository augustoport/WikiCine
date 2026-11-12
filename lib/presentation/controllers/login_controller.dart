import 'dart:developer';
import 'package:material_ui/material_ui.dart';

import '../../../core/locator.dart';
import '../../../domain/entities/user.dart';
import '../../domain/usecases/user/get_current_user_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';

class LoginController extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool loadingDrawer = false;
  User? currentUser;

  final _loginUseCase = getIt<LoginUseCase>();
  final _getCurrentUserUseCase = getIt<GetCurrentUserUseCase>();
  final _logoutUseCase = getIt<LogoutUseCase>();

  Future<bool> login() async {
    isLoading = true;
    notifyListeners();

    try {
      final user = await _loginUseCase(
        username: emailController.text,
        password: passwordController.text,
      );

      currentUser = user;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> checkExistingSession() async {
    try {
      loadingDrawer = true;
      notifyListeners();

      final user = await _getCurrentUserUseCase();
      if (user != null) {
        currentUser = user;
        notifyListeners();
      }
    } finally {
      loadingDrawer = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _logoutUseCase();
    currentUser = null;
    emailController.clear();
    passwordController.clear();
    notifyListeners();
  }
}

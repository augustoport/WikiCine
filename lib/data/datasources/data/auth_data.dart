import '../../../domain/entities/user.dart';
import '../../models/guest_session_model.dart';

abstract class AuthData {
  Future<User> login({required String username, required String password});
  Future<User> getAccountDetails(String sessionId);

  /// `GET /authentication/guest_session/new`.
  Future<GuestSessionModel> createGuestSession();
}

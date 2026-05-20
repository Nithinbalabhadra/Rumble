import '../models/app_user.dart';

class AuthService {
  static AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<AppUser?> signInAsGuest({String name = 'Guest'}) async {
    _currentUser = AppUser(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      displayName: name,
    );
    return _currentUser;
  }

  Future<void> signOut() async {
    _currentUser = null;
  }
}

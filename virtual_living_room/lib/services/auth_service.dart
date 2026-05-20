class AppUser {
  final String uid;
  final String displayName;

  AppUser({required this.uid, required this.displayName});
}

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

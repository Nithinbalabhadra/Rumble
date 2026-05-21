import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';

class AuthService {
  static const _kUid = 'auth_uid';
  static const _kName = 'auth_name';
  static const _kEmail = 'auth_email';
  static const _kMobile = 'auth_mobile';
  static const _kImage = 'auth_profile_image';
  static const _kVerified = 'auth_verified';

  static AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<AppUser?> restoreSession() async {
    if (_currentUser != null) return _currentUser;
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_kUid);
    if (uid == null) return null;

    _currentUser = AppUser(
      uid: uid,
      displayName: prefs.getString(_kName) ?? 'Rumble Player',
      email: prefs.getString(_kEmail) ?? '',
      mobileNumber: prefs.getString(_kMobile) ?? '',
      profileImagePath: prefs.getString(_kImage) ?? '',
      isVerifiedAtSignup: prefs.getBool(_kVerified) ?? false,
    );
    return _currentUser;
  }

  Future<AppUser?> signUpOnce({
    required String displayName,
    required String email,
    required String mobileNumber,
    required String profileImagePath,
    required bool isVerifiedAtSignup,
  }) async {
    final user = AppUser(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      displayName: displayName,
      email: email.trim().toLowerCase(),
      mobileNumber: mobileNumber.trim(),
      profileImagePath: profileImagePath.trim(),
      isVerifiedAtSignup: isVerifiedAtSignup,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUid, user.uid);
    await prefs.setString(_kName, user.displayName);
    await prefs.setString(_kEmail, user.email);
    await prefs.setString(_kMobile, user.mobileNumber);
    await prefs.setString(_kImage, user.profileImagePath);
    await prefs.setBool(_kVerified, user.isVerifiedAtSignup);

    _currentUser = user;
    return _currentUser;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUid);
    await prefs.remove(_kName);
    await prefs.remove(_kEmail);
    await prefs.remove(_kMobile);
    await prefs.remove(_kImage);
    await prefs.remove(_kVerified);
    _currentUser = null;
  }
}

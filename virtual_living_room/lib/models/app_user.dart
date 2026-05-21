class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final String mobileNumber;
  final String profileImagePath;
  final bool isVerifiedAtSignup;
  final bool isPremiumHost;

  AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.mobileNumber,
    required this.profileImagePath,
    required this.isVerifiedAtSignup,
    required this.isPremiumHost,
  });
}

import 'package:firebase_auth/firebase_auth.dart';

/// Service wrapping Firebase Authentication operations.
/// All user-facing error messages are in Turkish.
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Current user ──────────────────────────────────────────────────────────

  User? get currentUser => _auth.currentUser;

  // ── Register ──────────────────────────────────────────────────────────────

  /// Creates a new Firebase user with [email] and [password], then immediately
  /// sends an email-verification link.
  /// Throws a [FirebaseAuthException] on failure.
  Future<UserCredential> createUserAndSendVerification({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.sendEmailVerification();
    return credential;
  }

  // ── Email verification ────────────────────────────────────────────────────

  /// Re-sends the verification email to the currently signed-in user.
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Reloads the current user from Firebase and returns whether the email is verified.
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  /// Signs in with email and password.
  /// Returns the [UserCredential] on success.
  /// Throws a [FirebaseAuthException] on failure.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ── ID Token ──────────────────────────────────────────────────────────────

  /// Returns a fresh Firebase ID token for the current user, or null if not logged in.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return await _auth.currentUser?.getIdToken(forceRefresh);
  }

  // ── Password reset ────────────────────────────────────────────────────────

  /// Sends a password-reset email to [email].
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Turkish error messages ────────────────────────────────────────────────

  /// Converts a [FirebaseAuthException] code into a Turkish user-facing message.
  static String turkishErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı bir hesap bulunamadı.';
      case 'wrong-password':
        return 'Şifre hatalı. Lütfen tekrar deneyin.';
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter kullanın.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'too-many-requests':
        return 'Çok fazla başarısız giriş denemesi. Lütfen biraz bekleyin.';
      case 'network-request-failed':
        return 'Ağ bağlantısı hatası. İnternetinizi kontrol edin.';
      case 'operation-not-allowed':
        return 'Bu işleme izin verilmiyor. Lütfen yönetici ile iletişime geçin.';
      case 'requires-recent-login':
        return 'Bu işlem için yeniden giriş yapmanız gerekmektedir.';
      case 'expired-action-code':
        return 'Doğrulama bağlantısının süresi dolmuş. Yeni bir bağlantı isteyin.';
      case 'invalid-action-code':
        return 'Doğrulama bağlantısı geçersiz. Yeni bir bağlantı isteyin.';
      default:
        return 'Bir hata oluştu: ${e.message ?? e.code}';
    }
  }
}

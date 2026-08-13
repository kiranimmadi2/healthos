import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'phone_auth_service.dart';
import 'user_repository.dart';

/// Provider ids recorded on the user document, so the sign-in screen can tell
/// a returning user which method their account uses.
abstract final class AuthProviderId {
  static const password = 'password';
  static const google = 'google.com';
  static const phone = 'phone';

  /// Accounts created by the removed email-OTP flow. Nothing issues this any
  /// more; it is still recognised so those users can be offered a recovery
  /// path. See [AuthRepository.sendPasswordReset].
  static const legacyEmailLink = 'emailLink';
}

class AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final PhoneAuthService _phoneAuth;
  final UserRepository? _userRepository;

  AuthRepository(
    this._auth,
    this._googleSignIn, {
    PhoneAuthService? phoneAuthService,
    UserRepository? userRepository,
  })  : _phoneAuth = phoneAuthService ?? PhoneAuthService(_auth),
        _userRepository = userRepository;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  PhoneAuthService get phoneAuth => _phoneAuth;

  /// Fetches registered sign-in methods for an email address.
  /// Used to inform the user if an account exists under another provider (Password vs Google vs OTP).
  Future<List<String>> fetchSignInMethodsForEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) return [];
    try {
      final uid = await _userRepository?.findUidByEmail(cleanEmail);
      if (uid != null) {
        final userData = await _userRepository?.getUserData(uid);
        final providers = userData?['authProviders'] as List<dynamic>?;
        if (providers != null) {
          return providers.map((e) => e.toString()).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  /// Signs in with a code delivered by SMS.
  ///
  /// If someone is already signed in (an email or Google user adding a phone),
  /// the credential is linked to that account instead of creating a second one.
  Future<UserCredential> signInWithPhoneCredential(
    PhoneAuthCredential credential,
  ) async {
    final existingUser = _auth.currentUser;

    UserCredential result;
    if (existingUser != null) {
      try {
        result = await _phoneAuth.linkToCurrentUser(credential);
      } on FirebaseAuthException catch (e) {
        // The number already belongs to another account; sign in as that one.
        if (e.code == 'credential-already-in-use' ||
            e.code == 'provider-already-linked') {
          result = await _phoneAuth.signIn(credential);
        } else {
          rethrow;
        }
      }
    } else {
      result = await _phoneAuth.signIn(credential);
    }

    final user = result.user;
    if (user != null) {
      await _userRepository?.recordSignInProvider(
        user.uid,
        AuthProviderId.phone,
        email: user.email,
        name: user.displayName,
      );
    }
    return result;
  }

  /// Recovery path for accounts created by the removed email-OTP flow.
  ///
  /// Those accounts have a real Firebase password that was derived from the
  /// email address, so the user has never seen it and cannot type it. Sending a
  /// reset lets them set one they know.
  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final credential = await _auth.signInWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );
    if (credential.user != null) {
      await _userRepository?.recordSignInProvider(
        credential.user!.uid,
        AuthProviderId.password,
        email: cleanEmail,
      );
    }
    return credential;
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final credential = await _auth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );
    if (credential.user != null) {
      await _userRepository?.recordSignInProvider(
        credential.user!.uid,
        AuthProviderId.password,
        email: cleanEmail,
      );
    }
    return credential;
  }

  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()..addScope('email');
      final credential = await _auth.signInWithPopup(provider);
      if (credential.user != null) {
        await _userRepository?.recordSignInProvider(
          credential.user!.uid,
          AuthProviderId.google,
          email: credential.user!.email,
          name: credential.user!.displayName,
        );
      }
      return credential;
    }

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential googleCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential? resultCredential;

    final activeUser = _auth.currentUser;
    if (activeUser != null) {
      try {
        resultCredential =
            await activeUser.linkWithCredential(googleCredential);
      } catch (_) {
        resultCredential =
            await _auth.signInWithCredential(googleCredential);
      }
    } else {
      try {
        resultCredential =
            await _auth.signInWithCredential(googleCredential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // Automatic provider linking
          resultCredential =
              await _auth.signInWithCredential(googleCredential);
        } else {
          rethrow;
        }
      }
    }

    if (resultCredential?.user != null) {
      await _userRepository?.recordSignInProvider(
        resultCredential!.user!.uid,
        AuthProviderId.google,
        email: resultCredential.user!.email,
        name: resultCredential.user!.displayName,
      );
    }

    return resultCredential;
  }

  Future<void> signOut() async {
    // Drop the cached profile first: the memory cache is static, so without
    // this the next sign-in re-emits the previous user's profile.
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _userRepository?.clearCache(uid);
    }
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    return _auth.signOut();
  }
}

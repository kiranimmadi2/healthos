import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/theme.dart';
import '../../../shared/presentation/branding/app_logo.dart';
import '../../../shared/presentation/branding/google_logo.dart';
import '../../../shared/presentation/widgets/glass_container.dart';
import '../application/auth_providers.dart';
import '../data/auth_repository.dart';
import '../data/phone_auth_service.dart';

enum AuthMode { password, phone }

enum OtpStep { enterPhone, enterCode }

/// Country codes offered by the phone field.
///
/// Deliberately short — this is a dial-code prefix, not a full country picker.
const _dialCodes = <({String code, String label})>[
  (code: '+91', label: 'IN +91'),
  (code: '+1', label: 'US +1'),
  (code: '+44', label: 'UK +44'),
  (code: '+61', label: 'AU +61'),
  (code: '+971', label: 'AE +971'),
  (code: '+65', label: 'SG +65'),
];

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _phoneController = TextEditingController();
  final List<TextEditingController> _otpPinControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpPinFocusNodes =
      List.generate(6, (_) => FocusNode());

  AuthMode _authMode = AuthMode.password;
  OtpStep _otpStep = OtpStep.enterPhone;

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Timer? _resendTimer;
  int _resendCountdown = 0;
  List<String> _existingProviders = [];

  String _dialCode = _dialCodes.first.code;

  /// The number the code was sent to, in E.164. Shown back to the user and
  /// reused when resending.
  String? _pendingNumber;

  /// Firebase's handle for the in-flight verification (mobile).
  String? _verificationId;

  /// Passed back on resend so Firebase issues a new code rather than treating
  /// the request as a duplicate.
  int? _resendToken;

  /// Web returns this instead of a verification id.
  ConfirmationResult? _webConfirmation;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    for (final controller in _otpPinControllers) {
      controller.dispose();
    }
    for (final node in _otpPinFocusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _onEmailChanged() {
    final email = _emailController.text.trim();
    if (email.contains('@') && email.length > 5) {
      _checkExistingProviders(email);
    } else {
      if (_existingProviders.isNotEmpty) {
        setState(() => _existingProviders = []);
      }
    }
  }

  Future<void> _checkExistingProviders(String email) async {
    try {
      final methods = await ref
          .read(authRepositoryProvider)
          .fetchSignInMethodsForEmail(email);
      if (mounted) {
        setState(() => _existingProviders = methods);
      }
    } catch (_) {}
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _friendlyAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-not-found':
        return 'No account found for that email. Try signing up, or use Google.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists for that email. Try logging in or using Google.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method for this email. We are linking your providers.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';

      // ---- Phone verification -------------------------------------------
      case 'invalid-phone-number':
        return 'That phone number is not valid. Include your country code.';
      case 'invalid-verification-code':
        return 'That code is incorrect. Check the SMS and try again.';
      case 'session-expired':
        return 'That code has expired. Request a new one.';
      case 'quota-exceeded':
        return 'Too many codes requested right now. Please try again later.';
      case 'missing-client-identifier':
        // Android: the app's SHA-1/SHA-256 is not registered in Firebase, so
        // Play Integrity cannot attest the request.
        return 'This build is not registered for phone sign-in. '
            'Use email or Google for now.';
      case 'captcha-check-failed':
        return 'Verification check failed. Reload the page and try again.';
      case 'credential-already-in-use':
        return 'That phone number is already linked to another account.';

      case 'too-many-requests':
        return e.message ??
            'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendCountdown = PhoneAuthService.codeTimeout.inSeconds);

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _clearPin() {
    for (final controller in _otpPinControllers) {
      controller.clear();
    }
  }

  String _enteredCode() =>
      _otpPinControllers.map((c) => c.text.trim()).join();

  /// Requests an SMS code for the number in the form.
  ///
  /// [resend] reuses the number already in flight and passes Firebase's resend
  /// token, without which a second request may be silently ignored.
  Future<void> _sendCode({bool resend = false}) async {
    final number = resend
        ? _pendingNumber
        : toE164(_phoneController.text, _dialCode);

    if (number == null) {
      _showError('Enter a valid phone number, for example 98765 43210.');
      return;
    }

    setState(() => _isLoading = true);
    final service = ref.read(phoneAuthServiceProvider);

    try {
      if (PhoneAuthService.usesWebFlow) {
        final confirmation = await service.startVerificationOnWeb(number);
        if (!mounted) return;
        setState(() {
          _webConfirmation = confirmation;
          _pendingNumber = number;
          _otpStep = OtpStep.enterCode;
          _isLoading = false;
        });
        _clearPin();
        _startResendTimer();
        _showSuccess('Code sent to $number');
        return;
      }

      await service.startVerification(
        e164PhoneNumber: number,
        forceResendingToken: resend ? _resendToken : null,
        onCodeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _pendingNumber = number;
            _otpStep = OtpStep.enterCode;
            _isLoading = false;
          });
          _clearPin();
          _startResendTimer();
          _showSuccess('Code sent to $number');
        },
        // Android can retrieve the code itself, or verify the number without
        // one at all. Sign in immediately rather than asking for digits the
        // user will never see.
        onAutoVerified: (credential) async {
          if (!mounted) return;
          _showSuccess('Number verified automatically');
          await _completeSignIn(credential);
        },
        onFailed: (error) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          _showError(_friendlyAuthMessage(error));
        },
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(_friendlyAuthMessage(e));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Could not send the code. Please try again.');
      }
    }
  }

  /// Verifies the typed code and signs in.
  Future<void> _verifyCode() async {
    final code = _enteredCode();
    if (code.length != 6) {
      _showError('Enter all 6 digits of the code.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_webConfirmation != null) {
        await _webConfirmation!.confirm(code);
        return;
      }

      final verificationId = _verificationId;
      if (verificationId == null) {
        _showError('That code has expired. Request a new one.');
        return;
      }

      final credential = ref
          .read(phoneAuthServiceProvider)
          .credentialFor(verificationId: verificationId, smsCode: code);
      await _completeSignIn(credential);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _clearPin();
        _otpPinFocusNodes.first.requestFocus();
        _showError(_friendlyAuthMessage(e));
      }
    } catch (e) {
      if (mounted) _showError('Could not verify that code. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _completeSignIn(PhoneAuthCredential credential) async {
    await ref.read(authRepositoryProvider).signInWithPhoneCredential(credential);
    // The router redirects on the auth state change; nothing to do here.
  }

  /// Recovery for accounts made by the removed email-OTP flow, whose password
  /// was derived from the email address and never shown to the user.
  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showError('Enter your email address first.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
      if (mounted) _showSuccess('Password reset link sent to $email');
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(_friendlyAuthMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitPasswordAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (_isSignUp) {
        await ref
            .read(authRepositoryProvider)
            .signUpWithEmail(email, password);
      } else {
        await ref
            .read(authRepositoryProvider)
            .signInWithEmail(email, password);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(_friendlyAuthMessage(e));
    } catch (e) {
      if (mounted) _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      if (e.code != 'popup-closed-by-user' &&
          e.code != 'cancelled-popup-request' &&
          e.code != 'web-context-cancelled' &&
          mounted) {
        _showError(_friendlyAuthMessage(e));
      }
    } catch (e) {
      if (mounted) _showError('Google Sign-In failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassCanvas(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 460),
                child: GlassContainer(
                  borderRadius: 32,
                  blur: 24,
                  opacity: 0.70,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: AppLogo(size: 64)),
                      const SizedBox(height: 20),
                      Text(
                        'Welcome to HealthOS',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _authMode == AuthMode.phone
                            ? (_otpStep == OtpStep.enterPhone
                                ? 'Sign in with a code sent by SMS'
                                : 'Enter the code we texted you')
                            : (_isSignUp
                                ? 'Create your secure healthcare account'
                                : 'Sign in to continue to your care workspace'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: context.hos.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 24),
                      _buildAuthModeToggle(),
                      const SizedBox(height: 24),
                      if (_existingProviders.isNotEmpty) ...[
                        _buildProviderNoticeBanner(),
                        const SizedBox(height: 20),
                      ],
                      if (_authMode == AuthMode.password)
                        _buildPasswordAuthForm()
                      else
                        _buildOtpAuthForm(),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(color: context.hos.textMuted, fontSize: 12),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
                        ],
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        icon: const GoogleLogo(size: 20),
                        label: const Text('Continue with Google'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: Colors.white.withOpacity(0.5),
                          side: BorderSide(color: Colors.white.withOpacity(0.8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderNoticeBanner() {
    final providersStr = _existingProviders.map((p) {
      if (p == AuthProviderId.google) return 'Google';
      if (p == AuthProviderId.password) return 'Password';
      if (p == AuthProviderId.phone) return 'Phone';
      if (p == AuthProviderId.legacyEmailLink) return 'Email code (retired)';
      return p;
    }).join(', ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondarySoft,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.link_rounded, color: AppColors.secondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Account exists with $providersStr. Logging in will link all sign-in methods to your single account.',
              style: TextStyle(
                fontSize: 12,
                color: context.hos.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: context.hos.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _isLoading
                  ? null
                  : () => setState(() => _authMode = AuthMode.password),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _authMode == AuthMode.password
                      ? context.hos.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  boxShadow: _authMode == AuthMode.password
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: _authMode == AuthMode.password
                          ? AppColors.primary
                          : context.hos.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: _authMode == AuthMode.password
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: _authMode == AuthMode.password
                            ? AppColors.primary
                            : context.hos.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _isLoading
                  ? null
                  : () => setState(() => _authMode = AuthMode.phone),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _authMode == AuthMode.phone
                      ? context.hos.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  boxShadow: _authMode == AuthMode.phone
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sms_outlined,
                      size: 18,
                      color: _authMode == AuthMode.phone
                          ? AppColors.primary
                          : context.hos.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Phone',
                      style: TextStyle(
                        fontWeight: _authMode == AuthMode.phone
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: _authMode == AuthMode.phone
                            ? AppColors.primary
                            : context.hos.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordAuthForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'Please enter your email';
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          if (_isSignUp) ...[
            const SizedBox(height: 20),
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitPasswordAuth,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _isSignUp ? 'Create account' : 'Sign in securely',
                  ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed:
                _isLoading ? null : () => setState(() => _isSignUp = !_isSignUp),
            child: Text(
              _isSignUp
                  ? 'Already have an account? Sign in'
                  : 'New to HealthOS? Create an account',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!_isSignUp) _buildResetPasswordLink(),
        ],
      ),
    );
  }

  /// Escape hatch, and the migration path off the retired email-code flow.
  ///
  /// Accounts created that way were given a Firebase password derived from the
  /// email address, which the user has never seen and cannot type. A reset is
  /// the only way back into those accounts. The wording is deliberately generic
  /// so it reads as ordinary account recovery to everyone else.
  Widget _buildResetPasswordLink() {
    final usedRetiredEmailCode =
        _existingProviders.contains(AuthProviderId.legacyEmailLink) &&
        !_existingProviders.contains(AuthProviderId.password);

    return Column(
      children: [
        TextButton(
          onPressed: _isLoading ? null : _sendPasswordReset,
          child: Text(
            usedRetiredEmailCode
                ? 'Set a password for this account'
                : 'Trouble signing in? Reset your password',
            style: TextStyle(
              color: context.hos.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        if (usedRetiredEmailCode)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'This account used the old email-code sign-in, which has been '
              'replaced. Reset your password once, or continue with Google.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: context.hos.textMuted),
            ),
          ),
      ],
    );
  }

  Widget _buildOtpAuthForm() {
    if (_otpStep == OtpStep.enterPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 118, child: _buildDialCodeField()),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _phoneController,
                  label: 'Phone number',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _sendCode(),
            icon: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.sms_rounded, size: 20),
            label: Text(_isLoading ? 'Sending...' : 'Send code by SMS'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'We will text you a 6-digit code. Standard message rates '
                    'may apply.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryDark.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.hos.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.sms_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Code sent to:',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.hos.textSecondary,
                      ),
                    ),
                    Text(
                      _pendingNumber ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.hos.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Change number',
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  _resendTimer?.cancel();
                  setState(() {
                    _otpStep = OtpStep.enterPhone;
                    _verificationId = null;
                    _webConfirmation = null;
                    _resendCountdown = 0;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Enter 6-Digit OTP Code:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: context.hos.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => _buildPinBox(index)),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyCode,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Verify & Sign In'),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _resendCountdown > 0
                  ? 'Resend OTP in ${_resendCountdown}s'
                  : "Didn't get the code?",
              style: TextStyle(
                color: context.hos.textSecondary,
                fontSize: 13,
              ),
            ),
            if (_resendCountdown == 0)
              TextButton(
                onPressed: _isLoading ? null : () => _sendCode(resend: true),
                child: const Text(
                  'Resend code',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPinBox(int index) {
    final hasValue = _otpPinControllers[index].text.isNotEmpty;
    return SizedBox(
      width: 50,
      height: 56,
      child: TextField(
        controller: _otpPinControllers[index],
        focusNode: _otpPinFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        onChanged: (value) {
          setState(() {});
          if (value.length > 1) {
            // Handle pasting complete 6-digit code
            final digits = value.replaceAll(RegExp(r'\D'), '');
            for (var i = 0; i < 6 && i < digits.length; i++) {
              _otpPinControllers[i].text = digits[i];
            }
            if (digits.length >= 6) {
              _otpPinFocusNodes[5].unfocus();
              _verifyCode();
            }
            return;
          }

          if (value.isNotEmpty) {
            if (index < 5) {
              _otpPinFocusNodes[index + 1].requestFocus();
            } else {
              _otpPinFocusNodes[index].unfocus();
              _verifyCode();
            }
          } else if (value.isEmpty && index > 0) {
            _otpPinFocusNodes[index - 1].requestFocus();
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          fillColor: hasValue ? AppColors.primarySoft : Colors.white,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasValue ? AppColors.primary : context.hos.border,
              width: hasValue ? 1.5 : 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  /// Country dial-code selector shown beside the phone number field.
  Widget _buildDialCodeField() {
    return DropdownButtonFormField<String>(
      initialValue: _dialCode,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Code'),
      items: [
        for (final entry in _dialCodes)
          DropdownMenuItem(value: entry.code, child: Text(entry.label)),
      ],
      onChanged: _isLoading
          ? null
          : (value) {
              if (value != null) setState(() => _dialCode = value);
            },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      autofillHints: keyboardType == TextInputType.emailAddress
          ? const [AutofillHints.email]
          : const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

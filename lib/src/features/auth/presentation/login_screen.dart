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

enum AuthMode { password, otp }

enum OtpStep { enterEmail, enterCode }

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

  final _otpEmailController = TextEditingController();
  final List<TextEditingController> _otpPinControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpPinFocusNodes =
      List.generate(6, (_) => FocusNode());

  AuthMode _authMode = AuthMode.password;
  OtpStep _otpStep = OtpStep.enterEmail;

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Timer? _resendTimer;
  int _resendCountdown = 0;
  String? _lastSentOtpCode;
  List<String> _existingProviders = [];

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    _otpEmailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _otpEmailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpEmailController.dispose();
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
    final email = (_authMode == AuthMode.password
            ? _emailController.text
            : _otpEmailController.text)
        .trim();
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
        return 'No account found for that email. Try signing up or using OTP.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists for that email. Try logging in or using Google/OTP.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method for this email. We are linking your providers.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-otp':
        return e.message ?? 'Incorrect OTP code. Please check and try again.';
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

  void _startResendTimer(String email) {
    _resendTimer?.cancel();
    final otpService = ref.read(otpServiceProvider);
    final cooldown = otpService.getRemainingCooldownSeconds(email);
    setState(() => _resendCountdown = cooldown > 0 ? cooldown : 60);

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        if (mounted) setState(() => _resendCountdown--);
      } else {
        _resendTimer?.cancel();
      }
    });
  }

  Future<void> _sendOtp() async {
    final email = _otpEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showError('Please enter a valid email address.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final code = await ref.read(authRepositoryProvider).sendEmailOtp(email);
      _lastSentOtpCode = code;
      _startResendTimer(email);
      if (mounted) {
        setState(() => _otpStep = OtpStep.enterCode);
        _showSuccess('OTP verification code sent to $email');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(_friendlyAuthMessage(e));
    } catch (e) {
      if (mounted) _showError('Failed to send OTP code. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _autoFillTestCode() {
    const code = '123456';
    for (var i = 0; i < 6; i++) {
      _otpPinControllers[i].text = code[i];
    }
    _verifyOtp();
  }

  String _getEnteredPinCode() {
    return _otpPinControllers.map((c) => c.text.trim()).join();
  }

  Future<void> _verifyOtp() async {
    final email = _otpEmailController.text.trim();
    final otpCode = _getEnteredPinCode();

    if (otpCode.length != 6) {
      _showError('Please enter all 6 digits of the OTP code.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).verifyEmailOtp(email, otpCode);
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(_friendlyAuthMessage(e));
    } catch (e) {
      if (mounted) _showError('OTP verification failed. Please try again.');
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
                        _authMode == AuthMode.otp
                            ? (_otpStep == OtpStep.enterEmail
                                ? 'Sign in instantly with a 6-digit Email OTP code'
                                : 'Enter the verification code sent to your email')
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
      if (p == 'google.com') return 'Google';
      if (p == 'password') return 'Password';
      if (p == 'emailLink') return 'Email OTP';
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
                  : () => setState(() => _authMode = AuthMode.otp),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _authMode == AuthMode.otp
                      ? context.hos.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  boxShadow: _authMode == AuthMode.otp
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
                      Icons.mark_email_read_outlined,
                      size: 18,
                      color: _authMode == AuthMode.otp
                          ? AppColors.primary
                          : context.hos.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Email OTP',
                      style: TextStyle(
                        fontWeight: _authMode == AuthMode.otp
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: _authMode == AuthMode.otp
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
        ],
      ),
    );
  }

  Widget _buildOtpAuthForm() {
    if (_otpStep == OtpStep.enterEmail) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _otpEmailController,
            label: 'Email Address for OTP',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _sendOtp,
            icon: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 20),
            label: Text(_isLoading ? 'Sending...' : 'Send Verification OTP'),
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
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'We will send a 6-digit OTP code to verify your identity. No password needed.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryDark.withOpacity(0.9),
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
              const Icon(Icons.mark_email_read_rounded,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Code sent to:',
                      style: TextStyle(
                          fontSize: 12, color: context.hos.textSecondary),
                    ),
                    Text(
                      _otpEmailController.text.trim(),
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
                tooltip: 'Change email',
                icon: const Icon(Icons.edit_outlined,
                    size: 20, color: AppColors.primary),
                onPressed: () {
                  setState(() => _otpStep = OtpStep.enterEmail);
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
        const SizedBox(height: 10),
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 14),
            child: InkWell(
              onTap: _isLoading ? null : _autoFillTestCode,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondarySoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.flash_on_rounded,
                      size: 15,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _lastSentOtpCode != null
                            ? "Dev OTP: $_lastSentOtpCode"
                            : "Dev Test OTP: 123456",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyOtp,
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
                onPressed: _isLoading ? null : _sendOtp,
                child: const Text(
                  'Resend OTP',
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
              _verifyOtp();
            }
            return;
          }

          if (value.isNotEmpty) {
            if (index < 5) {
              _otpPinFocusNodes[index + 1].requestFocus();
            } else {
              _otpPinFocusNodes[index].unfocus();
              _verifyOtp();
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

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/auth_provider.dart';

class PhoneInputScreen extends ConsumerStatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  ConsumerState<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends ConsumerState<PhoneInputScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _useEmail = true;
  String? _oauthError;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      final uri = Uri.base;

      // Check for OAuth errors in query params
      final error = uri.queryParameters['error'];
      final desc = uri.queryParameters['error_description'];
      if (error != null) {
        _oauthError = desc?.replaceAll('+', ' ') ?? error;
        debugPrint('[PhoneInput] OAuth error from URL: $_oauthError');
      }

      // Check for OAuth tokens in fragment (redirect back from Google)
      if (uri.fragment.contains('access_token')) {
        debugPrint('[PhoneInput] OAuth tokens detected in URL fragment — session should be auto-recovered');
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);

      if (_useEmail) {
        final email = _emailController.text.trim();
        await authService.signInWithEmailOtp(email);
        if (mounted) {
          context.go('/auth/verify', extra: {'email': email});
        }
      } else {
        final phone = _phoneController.text.trim();
        await authService.signInWithPhone(phone);
        if (mounted) {
          context.go('/auth/verify', extra: {'phone': phone});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    debugPrint('[GoogleSignIn] button tapped — kIsWeb=$kIsWeb');

    try {
      final authService = ref.read(authServiceProvider);
      final String redirectTo = kIsWeb
          ? Uri.base.origin
          : 'io.supabase.healthos://login-callback';

      debugPrint('[GoogleSignIn] calling signInWithGoogle redirectTo=$redirectTo');
      await authService.signInWithGoogle(redirectTo: redirectTo);
      debugPrint('[GoogleSignIn] signInWithGoogle returned (no exception)');
    } catch (e, st) {
      debugPrint('[GoogleSignIn] ERROR: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: HosPageContainer(
          maxWidth: 480,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_oauthError != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error, size: 18),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            'Sign-in failed: $_oauthError',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _oauthError = null),
                          child: Icon(Icons.close, color: AppColors.error, size: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                const Spacer(),
                Text('Welcome to', style: AppTypography.bodyLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'HealthOS',
                  style: AppTypography.h1.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _useEmail
                      ? 'Your unified health platform. Enter your email to get started.'
                      : 'Your unified health platform. Enter your phone number to get started.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (_useEmail)
                  HosTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'you@example.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    onSubmitted: (_) => _sendOtp(),
                  )
                else
                  HosTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: '+91 98765 43210',
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                    onSubmitted: (_) => _sendOtp(),
                  ),
                const SizedBox(height: AppSpacing.lg),
                HosButton(
                  label: 'Send OTP',
                  onPressed: _sendOtp,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() => _useEmail = !_useEmail);
                    },
                    child: Text(
                      _useEmail
                          ? 'Use phone number instead'
                          : 'Use email instead',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: Text(
                        'OR',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                HosButton(
                  label: 'Sign in with Google',
                  onPressed: _signInWithGoogle,
                  isLoading: _isGoogleLoading,
                  isOutlined: true,
                ),
                const Spacer(flex: 2),
                Center(
                  child: Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/patient_provider.dart';

class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({super.key, this.phone, this.email});

  final String? phone;
  final String? email;

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  bool _isLoading = false;

  String get _identifier => widget.email ?? widget.phone ?? '';
  bool get _isEmail => widget.email != null;

  Future<void> _verifyOtp(String otp) async {
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.verifyOtp(
        email: widget.email,
        phone: widget.phone,
        token: otp,
      );

      if (!mounted) return;

      final patient = await ref.read(currentPatientProvider.future);
      if (patient == null) {
        context.go('/auth/setup');
      } else {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    final authService = ref.read(authServiceProvider);
    if (_isEmail) {
      await authService.signInWithEmailOtp(widget.email!);
    } else {
      await authService.signInWithPhone(widget.phone!);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/auth')),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                _isEmail ? 'Check your email' : 'Verify your phone',
                style: AppTypography.h2,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'We sent a 6-digit code to $_identifier',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_isLoading)
                const HosLoading(message: 'Verifying...')
              else
                HosOtpField(onCompleted: _verifyOtp),
              const SizedBox(height: AppSpacing.xl),
              TextButton(
                onPressed: _resendOtp,
                child: const Text('Resend OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

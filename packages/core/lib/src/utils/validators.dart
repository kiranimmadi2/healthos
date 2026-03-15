class Validators {
  Validators._();

  static const _phonePattern = r'^\+?[1-9]\d{9,14}$';
  static const _emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(_phonePattern).hasMatch(cleaned)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(_emailPattern).hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validateHealthId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Health ID is required';
    }
    if (!RegExp(r'^HOS-\d{4}-[A-Z0-9]{4}$').hasMatch(value)) {
      return 'Enter a valid Health ID (e.g. HOS-2024-AB12)';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Enter a valid 6-digit OTP';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
}

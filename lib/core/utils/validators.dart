// lib/core/utils/validators.dart
import 'package:educclass/core/constants/app_strings.dart';

class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.required_;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) return AppStrings.invalidEmail;
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return AppStrings.required_;
    if (value.length < 6) return AppStrings.passwordTooShort;
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return AppStrings.required_;
    if (value != original) return AppStrings.passwordsDontMatch;
    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName obligatoire' : AppStrings.required_;
    }
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.required_;
    final urlRegex = RegExp(r'^https?://');
    if (!urlRegex.hasMatch(value.trim())) return 'URL invalide (doit commencer par http:// ou https://)';
    return null;
  }
}

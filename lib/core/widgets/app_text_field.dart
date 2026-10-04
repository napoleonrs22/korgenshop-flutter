import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_text_styles.dart';

/// Поле ввода второго варианта макета: подпись сверху, иконка слева,
/// рамка со скруглением 12.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    required this.hint,
    required this.icon,
    this.controller,
    this.keyboardType,
    this.obscure = false,
    this.uppercaseLabel = false,
    this.labelColor = AppColors.textPrimary,
    this.errorText,
    this.trailing,
    this.inputFormatters,
    super.key,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscure;

  /// На экране регистрации подписи набраны капсом, на входе — нет.
  final bool uppercaseLabel;
  final Color labelColor;
  final String? errorText;
  final Widget? trailing;

  /// Нужны полям с кодом из письма: только цифры и не длиннее шести.
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: uppercaseLabel ? 8 : 0, bottom: 4),
          child: Text(
            uppercaseLabel ? label.toUpperCase() : label,
            style: AppTextStyles.label.copyWith(color: labelColor),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscure,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.inputPlaceholder,
            ),
            prefixIcon: Icon(icon, size: 20, color: AppColors.textMuted),
            prefixIconConstraints: const BoxConstraints(minWidth: 44),
            suffixIcon: trailing,
            filled: true,
            fillColor: AppColors.surface,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: _border(hasError ? Colors.red : AppColors.border),
            focusedBorder: _border(hasError ? Colors.red : AppColors.primary),
            border: _border(AppColors.border),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Text(
              errorText!,
              style: AppTextStyles.label.copyWith(color: Colors.red),
            ),
          ),
      ],
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadii.control),
    borderSide: BorderSide(color: color),
  );
}

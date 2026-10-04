import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Типографика Figma. Везде семейство Hanken Grotesk.
class AppTextStyles {
  const AppTextStyles._();

  static TextStyle _base({
    required double size,
    required double height,
    required FontWeight weight,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
  }) {
    return GoogleFonts.hankenGrotesk(
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  /// «KORGEN SHOP» в шапке.
  static TextStyle get logo => _base(
    size: 20,
    height: 28,
    weight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: -0.5,
  );

  /// Заголовок карточки товара, 32/40.
  static TextStyle get display => _base(
    size: 32,
    height: 40,
    weight: FontWeight.w700,
    letterSpacing: -0.64,
  );

  /// 20/28 bold — заголовки секций и hero.
  static TextStyle get h2 =>
      _base(size: 20, height: 28, weight: FontWeight.w700);

  /// 18/24 semibold — заголовки карточек.
  static TextStyle get h3 => _base(
    size: 18,
    height: 24,
    weight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  /// 24/32 semibold — крупная цена.
  static TextStyle get priceLarge => _base(
    size: 24,
    height: 32,
    weight: FontWeight.w600,
    color: AppColors.primary,
  );

  /// 20/28 bold — цена в карточке каталога.
  static TextStyle get price => _base(
    size: 20,
    height: 28,
    weight: FontWeight.w700,
    color: AppColors.primary,
  );

  /// 16/24 regular — основной текст.
  static TextStyle get body => _base(
    size: 16,
    height: 24,
    weight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  /// 14/20 regular — вторичный текст.
  static TextStyle get bodySmall => _base(
    size: 14,
    height: 20,
    weight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  /// 12/16 medium, tracking 0.6 — бейджи, лейблы, подписи навбара.
  static TextStyle get label => _base(
    size: 12,
    height: 16,
    weight: FontWeight.w500,
    color: AppColors.textTertiary,
    letterSpacing: 0.6,
  );

  /// 18/24 semibold — крупные кнопки.
  static TextStyle get buttonLarge =>
      _base(size: 18, height: 24, weight: FontWeight.w600, color: Colors.white);

  /// 16/24 regular — кнопки визарда.
  static TextStyle get buttonMedium =>
      _base(size: 16, height: 24, weight: FontWeight.w400, color: Colors.white);
}

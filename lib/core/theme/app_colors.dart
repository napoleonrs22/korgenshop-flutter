import 'package:flutter/material.dart';

/// Цветовые токены из Figma (файл 51HARcLy1OplzEiGxsiF9m).
class AppColors {
  const AppColors._();

  /// Основной синий бренда.
  static const primary = Color(0xFF004688);

  /// Фон круглых плашек-иконок, rgba(0, 70, 136, 0.1).
  static const primaryLight = Color(0x1A004688);

  /// Заливка активного таба нижней навигации и «мягких» бейджей.
  static const primaryPale = Color(0xFFD8E3FB);

  /// Текст поверх [primaryPale].
  static const primaryPaleText = Color(0xFF5A6579);

  static const textPrimary = Color(0xFF191C1E);
  static const textSecondary = Color(0xFF545F73);
  static const textTertiary = Color(0xFF424751);
  static const textMuted = Color(0xFF727782);

  /// Бордер карточек-контейнеров.
  static const border = Color(0xFFC2C6D3);

  /// Более светлый бордер карточек товаров и трек прогресс-бара.
  static const divider = Color(0xFFE1E2E4);
  static const progressTrack = Color(0xFFE1E2E4);

  static const surface = Colors.white;

  /// Фон экранов.
  static const background = Color(0xFFF8F9FB);

  /// Подложка под фото товара/проекта.
  static const imagePlaceholder = Color(0xFFF3F4F6);

  /// Фон тегов на карточках проектов.
  static const chipBackground = Color(0xFFEDEEF0);

  static const whatsapp = Color(0xFF25D366);
  static const whatsappLight = Color(0x1A25D366);

  /// Тень карточек-контейнеров: drop-shadow(0 1px 1px rgba(0,0,0,0.05)).
  static const cardShadow = [
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 1),
  ];

  /// Тень приподнятой карточки во втором варианте макета:
  /// 0 4px 6px -1px и 0 2px 4px -2px, оба rgba(0,0,0,0.1).
  static const elevatedShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -2,
    ),
  ];

  /// Плейсхолдер в полях ввода на экранах входа и регистрации.
  static const inputPlaceholder = Color(0xFF6B7280);

  /// Более мягкая «фирменная» тень: 0 0 12px rgba(0,70,136,0.08).
  static const brandShadow = [
    BoxShadow(color: Color(0x14004688), blurRadius: 12),
  ];
}

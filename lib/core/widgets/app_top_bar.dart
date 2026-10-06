import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

/// Шапка из Figma: 64px, белая, нижний бордер, лого по центру.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    this.onLeadingTap,
    this.showBackButton = false,
    this.compactLogo = false,
    this.action,
    super.key,
  });

  final VoidCallback? onLeadingTap;

  /// Виджет справа — например переключатель языка на экране профиля.
  /// Без него место остаётся пустым, но ширину сохраняет, чтобы лого
  /// не съезжало с центра.
  final Widget? action;

  /// Слева стрелка «назад» вместо щита-логотипа (экран карточки товара).
  final bool showBackButton;

  /// Лого прижато влево и уменьшено до 16px (экран квиз-визарда).
  final bool compactLogo;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final logo = Text(
      'KORGEN SHOP',
      style: compactLogo
          ? AppTextStyles.logo.copyWith(
              fontSize: 16,
              height: 24 / 16,
              letterSpacing: -0.4,
            )
          : AppTextStyles.logo,
    );

    final leading = _TopBarButton(
      onTap: onLeadingTap,
      child: showBackButton
          ? const AppIcon.square('arrow_back', size: 16)
          : const AppIcon('logo_mark', width: 22, height: 22),
    );

    final trailing = action ?? const SizedBox(width: 40, height: 40);

    return ColoredBox(
      color: AppColors.surface,
      // Scaffold резервирует preferredSize + статус-бар, поэтому строка 64px
      // уходит под SafeArea, а не под часы и индикаторы.
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: compactLogo
                ? [
                    leading,
                    const SizedBox(width: 16),
                    logo,
                    const Spacer(),
                    trailing,
                  ]
                : [leading, Expanded(child: Center(child: logo)), trailing],
          ),
        ),
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  const _TopBarButton({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(width: 40, height: 40, child: Center(child: child)),
    );
  }
}

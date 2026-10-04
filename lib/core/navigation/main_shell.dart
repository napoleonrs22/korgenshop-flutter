import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/providers/cart_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_icon.dart';
import '../l10n/locale_providers.dart';
import '../theme/app_radii.dart';

/// Описание вкладки нижней навигации.
class _NavItem {
  const _NavItem({
    required this.icon,
    required this.labelKey,
    required this.width,
    required this.height,
  });

  final String icon;

  /// Ключ подписи в словаре локали.
  final String labelKey;
  final double width;
  final double height;
}

const _navItems = <_NavItem>[
  _NavItem(icon: 'nav_quizzes', labelKey: 'nav.quizzes', width: 20, height: 20),
  _NavItem(icon: 'nav_catalog', labelKey: 'nav.catalog', width: 18, height: 18),
  _NavItem(icon: 'nav_home', labelKey: 'nav.home', width: 16, height: 18),
  _NavItem(icon: 'nav_cart', labelKey: 'nav.cart', width: 19.982, height: 20),
  _NavItem(icon: 'nav_profile', labelKey: 'nav.profile', width: 16, height: 16),
];

/// Каркас приложения: контент вкладки плюс нижняя навигация.
///
/// Вкладки живут в [StatefulNavigationShell], поэтому стек и скролл
/// каждой сохраняются при переключении.
class MainShell extends ConsumerWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const cartTabIndex = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: AppColors.cardShadow,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 16,
              bottom: 16,
              left: 4,
              right: 4,
            ),
            child: Row(
              children: [
                for (var i = 0; i < _navItems.length; i++)
                  Expanded(
                    child: _NavButton(
                      item: _navItems[i],
                      label: ref.strings.t(_navItems[i].labelKey),
                      selected: navigationShell.currentIndex == i,
                      badgeCount: i == cartTabIndex ? cartCount : 0,
                      onTap: () => _goBranch(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // Повторный тап по активной вкладке возвращает её в корень.
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final _NavItem item;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final icon = AppIcon(
      item.icon,
      width: item.width,
      height: item.height,
      color: selected ? AppColors.primary : AppColors.textTertiary,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          // Во втором варианте активная вкладка — белая «капсула» с бордером.
          color: selected ? AppColors.surface : Colors.transparent,
          border: selected ? Border.all(color: AppColors.border) : null,
          borderRadius: BorderRadius.circular(AppRadii.control),
          boxShadow: selected ? AppColors.cardShadow : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
              child: Center(
                child: badgeCount > 0
                    ? _WithBadge(count: badgeCount, child: icon)
                    : icon,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: AppTextStyles.label.copyWith(
                color: selected ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Синяя точка-счётчик поверх иконки корзины.
class _WithBadge extends StatelessWidget {
  const _WithBadge({required this.child, required this.count});

  final Widget child;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -8,
          child: Container(
            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
            padding: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                count > 99 ? '99+' : '$count',
                style: AppTextStyles.label.copyWith(
                  color: Colors.white,
                  fontSize: 9,
                  height: 14 / 9,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

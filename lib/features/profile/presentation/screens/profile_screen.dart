import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_locale.dart';
import '../../../../core/l10n/locale_providers.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_menu_sheet.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/icon_plate.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Профиля в Figma нет — экран-заглушка, которая заодно даёт вход
/// на «Реализованные проекты» и «Контакты и поддержка».
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        onLeadingTap: () => AppMenuSheet.show(context),
        action: const _LanguagePicker(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          Text(
            strings.t('profile.title'),
            style: AppTextStyles.h2.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(strings.t('profile.hint'), style: AppTextStyles.body),
          const SizedBox(height: 24),
          SurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const IconPlate(
                  size: 48,
                  child: AppIcon.square(
                    'nav_profile',
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? strings.t('profile.guest'),
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        user?.email ?? strings.t('profile.notSignedIn'),
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Подтверждение можно было пропустить при регистрации, поэтому
          // напоминание живёт в профиле, пока почта не подтверждена.
          if (user != null && !user.emailVerified) ...[
            const SizedBox(height: 16),
            SurfaceCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      strings.t('auth.verify.banner'),
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.verifyEmail),
                    child: Text(
                      strings.t('auth.verify.bannerCta'),
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () => user == null
                  ? context.push(AppRoutes.login)
                  : ref.read(authControllerProvider.notifier).logout(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.control),
                ),
              ),
              child: Text(
                strings.t(user == null ? 'profile.signIn' : 'profile.signOut'),
                style: AppTextStyles.buttonLarge,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _MenuTile(
            label: strings.t('menu.projects'),
            onTap: () => context.go(AppRoutes.projects),
          ),
          const SizedBox(height: 8),
          _MenuTile(
            label: strings.t('menu.support'),
            onTap: () => context.go(AppRoutes.support),
          ),
          const SizedBox(height: 8),
          _MenuTile(
            label: strings.t('profile.orders'),
            onTap: () => context.push(AppRoutes.orders),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      radius: AppRadii.control,
      shadows: const [],
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const AppIcon(
            'chevron_right',
            width: 7.4,
            height: 12,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

/// Компактный переключатель языка — живёт в шапке экрана профиля
/// вместо иконки поиска.
class _LanguagePicker extends ConsumerWidget {
  const _LanguagePicker();

  /// Короткие коды понятнее полных названий и не требуют перевода.
  static const _codes = {
    AppLocale.ru: 'RU',
    AppLocale.kk: 'KZ',
    AppLocale.en: 'EN',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.strings.locale;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.imagePlaceholder,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final locale in AppLocale.values)
            _LanguageChip(
              label: _codes[locale] ?? locale.code.toUpperCase(),
              selected: locale == current,
              onTap: () => ref.read(stringsProvider.notifier).setLocale(locale),
            ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

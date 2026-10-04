import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../navigation/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../l10n/locale_providers.dart';
import 'app_icon.dart';

/// Меню за иконкой слева в шапке: разделы, которых нет в нижней навигации.
class AppMenuSheet extends ConsumerWidget {
  const AppMenuSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => const AppMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KORGEN SHOP',
              style: AppTextStyles.logo.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _MenuRow(
              label: strings.t('menu.projects'),
              onTap: () {
                Navigator.of(context).pop();
                context.go(AppRoutes.projects);
              },
            ),
            _MenuRow(
              label: strings.t('menu.support'),
              onTap: () {
                Navigator.of(context).pop();
                context.go(AppRoutes.support);
              },
            ),
            _MenuRow(
              label: strings.t('menu.catalog'),
              onTap: () {
                Navigator.of(context).pop();
                context.go(AppRoutes.catalog);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/icon_plate.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/entities/support_info.dart';
import '../providers/support_providers.dart';
import '../../../../core/l10n/locale_providers.dart';
import '../../../../core/utils/whatsapp.dart';

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;
    final contact = ref.watch(contactInfoProvider);
    final faq = ref.watch(faqProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        showBackButton: true,
        onLeadingTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.home);
          }
        },
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
        children: [
          Text(
            strings.t('support.title'),
            style: AppTextStyles.h2.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(strings.t('support.subtitle'), style: AppTextStyles.body),
          const SizedBox(height: 24),
          contact.when(
            loading: () => const _CardPlaceholder(),
            error: (error, _) =>
                Text(strings.t('common.error', params: {'error': error})),
            data: (info) => _ContactCard(info: info),
          ),
          const SizedBox(height: 24),
          _WhatsAppCard(
            onTap: () async {
              final opened = await WhatsApp.open(
                strings.t(
                  'product.whatsappMessage',
                  params: {'subject': strings.t('support.title')},
                ),
              );

              if (opened || !context.mounted) return;

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(strings.t('product.whatsappUnavailable')),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
          ),
          const SizedBox(height: 24),
          faq.when(
            loading: () => const _CardPlaceholder(),
            error: (error, _) =>
                Text(strings.t('common.error', params: {'error': error})),
            data: (items) => _FaqCard(items: items),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.info});

  final ContactInfo info;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(
                'pin',
                width: 16,
                height: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(info.officeTitle, style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            info.company,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          for (final line in info.addressLines)
            Text(line, style: AppTextStyles.bodySmall),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.border, height: 1),
          ),
          Row(
            children: [
              const AppIcon.square('phone', size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(info.phoneTitle, style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 4),
          Text(info.phone, style: AppTextStyles.bodySmall),
          Text(
            info.workingHours,
            style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _WhatsAppCard extends ConsumerWidget {
  const _WhatsAppCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const IconPlate(
            size: 48,
            background: AppColors.whatsappLight,
            child: AppIcon.square(
              'whatsapp',
              size: 26.667,
              color: AppColors.whatsapp,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            strings.t('support.instantTitle'),
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          Text(
            strings.t('support.instantSubtitle'),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: AppColors.whatsapp,
              borderRadius: BorderRadius.circular(2),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    strings.t('support.whatsappCta'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.label.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqCard extends ConsumerWidget {
  const _FaqCard({required this.items});

  final List<FaqItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.t('support.faqTitle'), style: AppTextStyles.h3),
          const SizedBox(height: 16),
          for (var i = 0; i < items.length; i++) ...[
            _FaqRow(item: items[i]),
            if (i != items.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

/// Аккордеон FAQ: строка со стрелкой, по тапу раскрывается ответ.
class _FaqRow extends StatefulWidget {
  const _FaqRow({required this.item});

  final FaqItem item;

  @override
  State<_FaqRow> createState() => _FaqRowState();
}

class _FaqRowState extends State<_FaqRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: const AppIcon(
                      'chevron_right',
                      width: 7.4,
                      height: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(widget.item.answer, style: AppTextStyles.bodySmall),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardPlaceholder extends StatelessWidget {
  const _CardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 160,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

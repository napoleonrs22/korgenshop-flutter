import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_providers.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/remote_image.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/order.dart';
import '../providers/orders_providers.dart';

/// История заказов пользователя со списком купленных товаров.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;
    final signedIn = ref.watch(isSignedInProvider);
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        showBackButton: true,
        onLeadingTap: () => context.pop(),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(ordersProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          children: [
            Text(
              strings.t('orders.title'),
              style: AppTextStyles.h2.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            if (!signedIn)
              _Notice(
                text: strings.t('orders.signInRequired'),
                actionLabel: strings.t('profile.signIn'),
                onAction: () => context.push(AppRoutes.login),
              )
            else
              ...orders.when(
                loading: () => const [
                  Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
                error: (error, _) => [
                  _Notice(
                    text: strings.t(
                      'orders.error',
                      params: {'error': error},
                    ),
                    actionLabel: strings.t('orders.retry'),
                    onAction: () => ref.invalidate(ordersProvider),
                  ),
                ],
                data: (items) => items.isEmpty
                    ? [
                        _Notice(
                          text: strings.t('orders.empty'),
                          actionLabel: strings.t('cart.openCatalog'),
                          onAction: () => context.go(AppRoutes.catalog),
                        ),
                      ]
                    : [
                        for (final order in items) ...[
                          _OrderCard(order: order, strings: strings),
                          const SizedBox(height: 12),
                        ],
                      ],
              ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.strings});

  final Order order;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.t('orders.number', params: {'id': order.id}),
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (order.statusTitle.isNotEmpty) _StatusChip(order.statusTitle),
            ],
          ),
          if (order.createdAt != null) ...[
            const SizedBox(height: 4),
            Text(_date(order.createdAt!), style: AppTextStyles.bodySmall),
          ],
          const SizedBox(height: 16),
          for (final item in order.items) ...[
            _ItemRow(item: item, strings: strings),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    strings.t(
                      'orders.itemsCount',
                      params: {'count': order.totalCount},
                    ),
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                Text(
                  Money.format(order.total),
                  style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          if (order.place != null) ...[
            const SizedBox(height: 8),
            Text(order.place!, style: AppTextStyles.bodySmall),
          ],
        ],
      ),
    );
  }

  /// Без intl: дата нужна только в одном формате.
  String _date(DateTime value) {
    final local = value.toLocal();
    String two(int part) => part.toString().padLeft(2, '0');

    return '${two(local.day)}.${two(local.month)}.${local.year}';
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, required this.strings});

  final OrderItem item;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.control),
          child: SizedBox(
            width: 56,
            height: 56,
            child: RemoteImage(item.image),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.quantity} × ${Money.format(item.price)}',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          Money.format(item.lineTotal),
          style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.imagePlaceholder,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

/// Сообщение с одной кнопкой: нет входа, пустой список или ошибка.
class _Notice extends StatelessWidget {
  const _Notice({
    required this.text,
    required this.actionLabel,
    required this.onAction,
  });

  final String text;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(text, textAlign: TextAlign.center, style: AppTextStyles.body),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.control),
                ),
              ),
              child: Text(
                actionLabel,
                style: AppTextStyles.label.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

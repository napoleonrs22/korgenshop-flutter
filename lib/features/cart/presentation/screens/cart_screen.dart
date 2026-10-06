import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_menu_sheet.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/cart_providers.dart';
import '../../../../core/l10n/locale_providers.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/widgets/remote_image.dart';
import '../../../../core/utils/money.dart';

/// В макете корзина есть только иконкой в навбаре, поэтому экран собран
/// на тех же токенах, но без отдельного эталона в Figma.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;
    final lines = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final signedIn = ref.watch(isSignedInProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        onLeadingTap: () => AppMenuSheet.show(context),
      ),
      // Заказ привязывается к аккаунту, поэтому корзина за входом:
      // иначе человек соберёт её и упрётся в авторизацию на оформлении.
      body: !signedIn
          ? const _AuthRequired()
          : lines.isEmpty
          ? _EmptyCart(onOpenCatalog: () => context.go(AppRoutes.catalog))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              children: [
                Text(
                  strings.t('cart.title'),
                  style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.t('cart.itemsCount', params: {'count': lines.length}),
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 24),
                for (final line in lines) ...[
                  _CartRow(
                    line: line,
                    onIncrease: () =>
                        ref.read(cartProvider.notifier).add(line.product),
                    onDecrease: () => ref
                        .read(cartProvider.notifier)
                        .decrease(line.product.id),
                    onRemove: () =>
                        ref.read(cartProvider.notifier).remove(line.product.id),
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 8),
                SurfaceCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            strings.t('cart.total'),
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(Money.format(total), style: AppTextStyles.price),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          label: strings.t('cart.checkout'),
                          onPressed: () => context.push(AppRoutes.checkout),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Экран для гостя: без аккаунта корзина не собирается.
class _AuthRequired extends ConsumerWidget {
  const _AuthRequired();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              strings.t('cart.authTitle'),
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              strings.t('cart.authHint'),
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => context.push(AppRoutes.login),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.control),
                  ),
                ),
                child: Text(
                  strings.t('profile.signIn'),
                  style: AppTextStyles.label.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.push(AppRoutes.register),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.control),
                  ),
                ),
                child: Text(
                  strings.t('auth.signUp'),
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({
    required this.line,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final CartLine line;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      radius: AppRadii.card,
      borderColor: AppColors.divider,
      shadows: const [],
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            color: AppColors.imagePlaceholder,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: RemoteImage(
                line.product.images.isEmpty ? null : line.product.images.first,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Money.format(line.total),
                  style: AppTextStyles.price.copyWith(
                    fontSize: 16,
                    height: 24 / 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QtyButton(icon: Icons.remove, onTap: onDecrease),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${line.quantity}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _QtyButton(icon: Icons.add, onTap: onIncrease),
                    const Spacer(),
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: AppColors.textMuted,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(2),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Icon(icon, size: 16, color: AppColors.textTertiary),
      ),
    );
  }
}

class _EmptyCart extends ConsumerWidget {
  const _EmptyCart({required this.onOpenCatalog});

  final VoidCallback onOpenCatalog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: AppColors.border,
            ),
            const SizedBox(height: 16),
            Text(
              strings.t('cart.empty'),
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              strings.t('cart.emptyHint'),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: strings.t('cart.openCatalog'),
              onPressed: onOpenCatalog,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ],
        ),
      ),
    );
  }
}

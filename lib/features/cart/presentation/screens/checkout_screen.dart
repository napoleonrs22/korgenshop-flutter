import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/locale_providers.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/order_api.dart';
import '../providers/cart_providers.dart';
import '../../data/payment_api.dart';
import '../../../../core/widgets/remote_image.dart';

import 'package:url_launcher/url_launcher.dart';

/// Оформление заказа: состав корзины уходит на сервер одним запросом.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _comment = TextEditingController();

  final _errors = <String, String?>{};
  bool _busy = false;

  @override
  void initState() {
    super.initState();

    // Поля профиля подставляем сразу, чтобы не заполнять их заново.
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user != null) {
      _name.text = user.name;
      _phone.text = user.phone;
      _email.text = user.email;
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _phone,
      _email,
      _city,
      _address,
      _comment,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final strings = ref.read(stringsProvider);
    final lines = ref.read(cartProvider);
    final required = strings.t('cart.errorRequired');

    setState(() {
      _errors
        ..['name'] = _name.text.trim().isEmpty ? required : null
        ..['phone'] = _phone.text.trim().isEmpty ? required : null
        ..['email'] = _email.text.contains('@') ? null : required
        ..['city'] = _city.text.trim().isEmpty ? required : null
        ..['address'] = _address.text.trim().isEmpty ? required : null;
    });

    if (_errors.values.any((value) => value != null)) return;
    if (lines.isEmpty) return;

    setState(() => _busy = true);

    try {
      final id = await OrderApiDataSource(ref.read(apiClientProvider))
          .createOrder(
            lines: lines,
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            email: _email.text.trim(),
            city: _city.text.trim(),
            address: _address.text.trim(),
            comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
          );

      if (!mounted) return;

      ref.read(cartProvider.notifier).clear();

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(strings.t('cart.success', params: {'id': id})),
            behavior: SnackBarBehavior.floating,
          ),
        );

      context.go(AppRoutes.catalog);
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        for (final field in ['name', 'phone', 'email', 'city', 'address']) {
          _errors[field] = error.errorFor(field) ?? _errors[field];
        }
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.strings;
    final lines = ref.watch(cartProvider);
    final total = lines.fold<int>(0, (sum, line) => sum + line.total);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        showBackButton: true,
        onLeadingTap: () => context.pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          Text(
            strings.t('cart.checkoutTitle'),
            style: AppTextStyles.h2.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          for (final field in [
            (
              'name',
              strings.t('cart.name'),
              strings.t('cart.nameHint'),
              Icons.person_outline,
              _name,
              TextInputType.name,
            ),
            (
              'phone',
              strings.t('cart.phone'),
              strings.t('cart.phoneHint'),
              Icons.phone_outlined,
              _phone,
              TextInputType.phone,
            ),
            (
              'email',
              strings.t('cart.email'),
              strings.t('cart.emailHint'),
              Icons.mail_outline,
              _email,
              TextInputType.emailAddress,
            ),
            (
              'city',
              strings.t('cart.city'),
              strings.t('cart.cityHint'),
              Icons.location_city_outlined,
              _city,
              TextInputType.text,
            ),
            (
              'address',
              strings.t('cart.address'),
              strings.t('cart.addressHint'),
              Icons.place_outlined,
              _address,
              TextInputType.streetAddress,
            ),
            (
              'comment',
              strings.t('cart.comment'),
              strings.t('cart.commentHint'),
              Icons.chat_bubble_outline,
              _comment,
              TextInputType.text,
            ),
          ]) ...[
            AppTextField(
              label: field.$2,
              hint: field.$3,
              icon: field.$4,
              controller: field.$5,
              keyboardType: field.$6,
              errorText: _errors[field.$1],
            ),
            const SizedBox(height: 16),
          ],
          const _PaymentSection(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.t('cart.total'),
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              ),
              Text(Money.format(total), style: AppTextStyles.price),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _busy || lines.isEmpty ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.control),
                ),
              ),
              child: Text(
                lines.isEmpty
                    ? strings.t('cart.emptyForCheckout')
                    : strings.t('cart.submit'),
                style: AppTextStyles.buttonLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Выбор способа оплаты и реквизиты Kaspi.
class _PaymentSection extends ConsumerWidget {
  const _PaymentSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;
    final methods = ref.watch(paymentMethodsProvider);
    final selected = ref.watch(paymentMethodProvider);

    return methods.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => const SizedBox.shrink(),
      data: (items) {
        final kaspi = items
            .where((item) => item.value == selected)
            .map((item) => item.kaspi)
            .firstOrNull;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.t('cart.payment'),
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            for (final method in items) ...[
              _PaymentOption(
                title: method.title,
                selected: method.value == selected,
                onTap: () => ref.read(paymentMethodProvider.notifier).state =
                    method.value,
              ),
              const SizedBox(height: 8),
            ],
            if (kaspi != null) _KaspiBox(details: kaspi),
          ],
        );
      },
    );
  }
}

class _KaspiBox extends ConsumerWidget {
  const _KaspiBox({required this.details});

  final KaspiDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.t('cart.kaspiTitle'),
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(details.hint, style: AppTextStyles.bodySmall),
          if (details.qr != null) ...[
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 180,
                height: 180,
                child: RemoteImage(details.qr, fit: BoxFit.contain),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (details.url != null)
            SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: () => launchUrl(
                  Uri.parse(details.url!),
                  mode: LaunchMode.externalApplication,
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.control),
                  ),
                ),
                child: Text(
                  strings.t('cart.kaspiOpen'),
                  style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                ),
              ),
            )
          else
            Text(
              strings.t('cart.kaspiNoLink'),
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

/// Строка выбора способа оплаты — в стиле переключателя языка в профиле.
class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.control),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body.copyWith(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

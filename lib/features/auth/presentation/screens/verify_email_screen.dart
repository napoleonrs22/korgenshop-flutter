import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/locale_providers.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_layout.dart';
import '../widgets/resend_control.dart';

/// Подтверждение почты шестизначным кодом.
///
/// Открывается сразу после регистрации: письмо уже ушло, поэтому отсчёт
/// до повторной отправки стартует с полной минуты.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _code = TextEditingController();

  bool _busy = false;
  String? _codeError;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final strings = ref.read(stringsProvider);
    final code = _code.text.trim();

    if (code.length != 6) {
      setState(() => _codeError = strings.t('auth.verify.errorCode'));
      return;
    }

    setState(() {
      _busy = true;
      _codeError = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).verifyEmail(code);

      if (!mounted) return;

      _toast(strings.t('auth.verify.success'));
      context.go(AppRoutes.profile);
    } catch (error) {
      if (!mounted) return;
      setState(() => _codeError = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<int> _resend() async {
    final strings = ref.read(stringsProvider);

    try {
      await ref.read(authRepositoryProvider).resendEmailCode();
      if (mounted) _toast(strings.t('auth.verify.resent'));
    } catch (error) {
      if (mounted) _toast('$error');
    }

    return 60;
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.strings;
    final email = ref.watch(authControllerProvider).valueOrNull?.email ?? '';

    return AuthLayout(
      title: strings.t('auth.verify.title'),
      // Адрес известен всегда, кроме случая, когда экран открыли без сессии —
      // тогда подставлять пустоту в предложение некрасиво.
      subtitle: email.isEmpty
          ? strings.t('auth.verify.subtitleNoEmail')
          : strings.t('auth.verify.subtitle', params: {'email': email}),
      children: [
        AppTextField(
          label: strings.t('auth.verify.codeLabel'),
          hint: strings.t('auth.verify.codeHint'),
          icon: Icons.mail_outline,
          controller: _code,
          keyboardType: TextInputType.number,
          errorText: _codeError,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(
          label: strings.t('auth.verify.submit'),
          onPressed: _busy ? null : _submit,
        ),
        const SizedBox(height: 8),
        ResendControl(
          initialSeconds: 60,
          label: strings.t('auth.verify.resend'),
          countdownText: (left) =>
              strings.t('auth.verify.resendIn', params: {'seconds': left}),
          onResend: _resend,
        ),
        const SizedBox(height: 16),
        // Подтверждение можно отложить: без него каталог и заказы работают,
        // упрёмся только там, где почта действительно нужна.
        Align(
          child: GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: Text(
              strings.t('auth.verify.later'),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

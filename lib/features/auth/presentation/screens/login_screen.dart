import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/locale_providers.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_providers.dart';
import '../../../../core/network/api_exception.dart';

/// Вход в аккаунт (node 13:447 второго варианта макета).
///
/// Только почта и пароль: кнопки соцсетей из макета не переносим.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _obscure = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final strings = ref.read(stringsProvider);
    final email = _email.text.trim();

    setState(() {
      _emailError = email.contains('@') && email.contains('.')
          ? null
          : strings.t('auth.errorEmail');
      _passwordError = _password.text.trim().isEmpty
          ? strings.t('auth.errorPassword')
          : null;
    });

    if (_emailError != null || _passwordError != null) return;

    await ref
        .read(authControllerProvider.notifier)
        .login(email: email, password: _password.text.trim());

    if (!mounted) return;

    final state = ref.read(authControllerProvider);

    state.when(
      data: (user) {
        if (user == null) return;
        context.go(AppRoutes.profile);
      },
      loading: () {},
      error: (error, _) => _showError(error),
    );
  }

  /// Ошибку валидации показываем под полем, остальное — снекбаром.
  void _showError(Object error) {
    if (error is ApiException && error.isValidation) {
      setState(() {
        _emailError = error.errorFor('email') ?? _emailError;
        _passwordError = error.errorFor('password') ?? _passwordError;
      });
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$error'), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.strings;
    final busy = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            const _BackButton(),
            const SizedBox(height: 16),
            // Align: в ListView поперечное ограничение жёсткое,
            // без него плашка растянулась бы на всю ширину.
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.imagePlaceholder,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadii.control),
                  boxShadow: AppColors.cardShadow,
                ),
                child: const Center(
                  child: AppIcon('logo_mark', width: 22, height: 22),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('KORGEN SHOP', style: AppTextStyles.logo),
            const SizedBox(height: 8),
            Text(
              strings.t('auth.loginSubtitle'),
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 48),
            AppTextField(
              label: strings.t('auth.emailLabel'),
              hint: strings.t('auth.emailHint'),
              icon: Icons.mail_outline,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              errorText: _emailError,
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: strings.t('auth.passwordLabel'),
              hint: strings.t('auth.passwordHint'),
              icon: Icons.lock_outline,
              controller: _password,
              obscure: _obscure,
              errorText: _passwordError,
              trailing: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: AppColors.textMuted,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.forgotPassword),
                child: Text(
                  strings.t('auth.forgotPassword'),
                  style: AppTextStyles.label.copyWith(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: busy ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.control),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      strings.t('auth.login'),
                      style: AppTextStyles.label.copyWith(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  strings.t('auth.noAccount'),
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.register),
                  child: Text(
                    strings.t('auth.signUp'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Кнопка возврата: экраны входа открываются поверх вкладок и своей
/// шапки не имеют.
class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    if (!context.canPop()) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => context.pop(),
        borderRadius: BorderRadius.circular(AppRadii.control),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.arrow_back,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

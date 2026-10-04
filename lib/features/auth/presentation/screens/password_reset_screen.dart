import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_providers.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_layout.dart';
import '../widgets/resend_control.dart';

/// Шаги восстановления пароля.
enum _Step { email, code, password }

/// Восстановление пароля: почта → код из письма → новый пароль.
///
/// Все три шага живут в одном экране: так email и код остаются в одном
/// месте, а кнопка «назад» возвращает на предыдущий шаг, а не выкидывает
/// из потока целиком.
class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _repeat = TextEditingController();

  _Step _step = _Step.email;
  bool _busy = false;
  bool _obscure = true;
  int _retryAfter = 60;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  /// Общая обёртка шага: гасит кнопку, показывает ошибку под полем.
  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await action();
    } catch (error) {
      if (mounted) setState(() => _error = _readable(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// У 422 сервер кладёт причину либо в message, либо в errors по полю.
  String _readable(Object error) {
    if (error is ApiException) {
      return error.errorFor('email') ??
          error.errorFor('code') ??
          error.errorFor('password') ??
          error.message;
    }

    return '$error';
  }

  Future<void> _sendCode() {
    final strings = ref.read(stringsProvider);
    final email = _email.text.trim();

    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _error = strings.t('auth.errorEmail'));
      return Future.value();
    }

    return _run(() async {
      final retryAfter = await ref
          .read(authRepositoryProvider)
          .requestPasswordCode(email);

      if (!mounted) return;

      setState(() {
        _retryAfter = retryAfter;
        _step = _Step.code;
      });
    });
  }

  Future<void> _checkCode() {
    final strings = ref.read(stringsProvider);

    if (_code.text.trim().length != 6) {
      setState(() => _error = strings.t('auth.reset.errorCode'));
      return Future.value();
    }

    return _run(() async {
      await ref
          .read(authRepositoryProvider)
          .checkPasswordCode(
            email: _email.text.trim(),
            code: _code.text.trim(),
          );

      if (mounted) setState(() => _step = _Step.password);
    });
  }

  Future<void> _savePassword() {
    final strings = ref.read(stringsProvider);

    // Обрезаем пробелы по краям: экранная клавиатура Android любит
    // дописывать пробел после слова, на экране он не виден, а строки
    // уже разные — и «Пароли не совпадают» появлялось на одинаковых.
    final password = _password.text.trim();
    final repeat = _repeat.text.trim();

    if (password.length < 8) {
      setState(() => _error = strings.t('auth.reset.errorPassword'));
      return Future.value();
    }

    if (password != repeat) {
      setState(() => _error = strings.t('auth.reset.errorRepeat'));
      return Future.value();
    }

    return _run(() async {
      await ref
          .read(authControllerProvider.notifier)
          .resetPassword(
            email: _email.text.trim(),
            code: _code.text.trim(),
            password: password,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(strings.t('auth.reset.success')),
            behavior: SnackBarBehavior.floating,
          ),
        );

      // Сервер уже вернул новый токен — пользователь вошёл.
      context.go(AppRoutes.profile);
    });
  }

  Future<int> _resend() async {
    try {
      return await ref
          .read(authRepositoryProvider)
          .requestPasswordCode(_email.text.trim());
    } catch (error) {
      if (mounted) setState(() => _error = _readable(error));
      return 60;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.strings;

    return AuthLayout(
      title: strings.t('auth.reset.title'),
      onBack: switch (_step) {
        _Step.email => context.canPop() ? context.pop : null,
        _Step.code => () => setState(() {
          _step = _Step.email;
          _error = null;
        }),
        _Step.password => () => setState(() {
          _step = _Step.code;
          _error = null;
        }),
      },
      subtitle: switch (_step) {
        _Step.email => strings.t('auth.reset.emailStep'),
        _Step.code => strings.t(
          'auth.reset.codeStep',
          params: {'email': _email.text.trim()},
        ),
        _Step.password => strings.t('auth.reset.passwordStep'),
      },
      children: switch (_step) {
        _Step.email => _emailStep(strings),
        _Step.code => _codeStep(strings),
        _Step.password => _passwordStep(strings),
      },
    );
  }

  List<Widget> _emailStep(AppStrings strings) => [
    AppTextField(
      label: strings.t('auth.emailLabel'),
      hint: strings.t('auth.emailHint'),
      icon: Icons.mail_outline,
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      errorText: _error,
    ),
    const SizedBox(height: 24),
    AuthPrimaryButton(
      label: strings.t('auth.reset.sendCode'),
      onPressed: _busy ? null : _sendCode,
    ),
    const SizedBox(height: 24),
    _backToLogin(strings),
  ];

  List<Widget> _codeStep(AppStrings strings) => [
    AppTextField(
      label: strings.t('auth.reset.codeLabel'),
      hint: strings.t('auth.reset.codeHint'),
      icon: Icons.mail_outline,
      controller: _code,
      keyboardType: TextInputType.number,
      errorText: _error,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
    ),
    const SizedBox(height: 24),
    AuthPrimaryButton(
      label: strings.t('auth.reset.continueLabel'),
      onPressed: _busy ? null : _checkCode,
    ),
    const SizedBox(height: 8),
    ResendControl(
      initialSeconds: _retryAfter,
      label: strings.t('auth.reset.resend'),
      countdownText: (left) =>
          strings.t('auth.reset.resendIn', params: {'seconds': left}),
      onResend: _resend,
    ),
  ];

  List<Widget> _passwordStep(AppStrings strings) => [
    AppTextField(
      label: strings.t('auth.reset.newPassword'),
      hint: strings.t('auth.passwordHint'),
      icon: Icons.lock_outline,
      controller: _password,
      obscure: _obscure,
      trailing: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: AppColors.textMuted,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    ),
    const SizedBox(height: 24),
    AppTextField(
      label: strings.t('auth.reset.repeatPassword'),
      hint: strings.t('auth.passwordHint'),
      icon: Icons.lock_outline,
      controller: _repeat,
      obscure: _obscure,
      errorText: _error,
    ),
    const SizedBox(height: 24),
    AuthPrimaryButton(
      label: strings.t('auth.reset.save'),
      onPressed: _busy ? null : _savePassword,
    ),
  ];

  Widget _backToLogin(AppStrings strings) => Align(
    child: GestureDetector(
      onTap: () => context.go(AppRoutes.login),
      child: Text(
        strings.t('auth.reset.backToLogin'),
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
      ),
    ),
  );
}

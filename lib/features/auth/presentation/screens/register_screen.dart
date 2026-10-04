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

/// Регистрация (node 13:507 второго варианта макета).
///
/// Только почта и пароль: кнопки Google и Apple из макета не переносим.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _address = TextEditingController();

  bool _obscure = true;
  bool _acceptedTerms = false;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  bool _termsError = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final strings = ref.read(stringsProvider);
    final email = _email.text.trim();

    setState(() {
      _nameError = _name.text.trim().isEmpty
          ? strings.t('auth.errorName')
          : null;
      _emailError = email.contains('@') && email.contains('.')
          ? null
          : strings.t('auth.errorEmail');
      _phoneError = _phone.text.trim().isEmpty
          ? strings.t('auth.errorPhone')
          : null;
      _passwordError = _password.text.trim().isEmpty
          ? strings.t('auth.errorPassword')
          : null;
      _termsError = !_acceptedTerms;
    });

    final hasError =
        _nameError != null ||
        _emailError != null ||
        _phoneError != null ||
        _passwordError != null ||
        _termsError;
    if (hasError) return;

    await ref
        .read(authControllerProvider.notifier)
        .register(
          name: _name.text.trim(),
          email: email,
          phone: _phone.text.trim(),
          password: _password.text.trim(),
          fullAddress: _address.text.trim().isEmpty
              ? null
              : _address.text.trim(),
        );

    if (!mounted) return;

    ref
        .read(authControllerProvider)
        .when(
          data: (user) {
            if (user == null) return;
            // Письмо с кодом сервер отправил при регистрации — ведём
            // человека сразу на подтверждение, пропустить его можно там.
            context.go(AppRoutes.verifyEmail);
          },
          loading: () {},
          error: (error, _) => _showError(error),
        );
  }

  /// Ошибки валидации раскладываем по полям формы.
  void _showError(Object error) {
    if (error is ApiException && error.isValidation) {
      setState(() {
        _nameError = error.errorFor('name') ?? _nameError;
        _emailError = error.errorFor('email') ?? _emailError;
        _phoneError = error.errorFor('phone') ?? _phoneError;
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _BackButton(),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadii.card),
                boxShadow: AppColors.elevatedShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: AppIcon('logo_mark', width: 28, height: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    strings.t('auth.registerTitle'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.logo,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.t('auth.registerSubtitle'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: strings.t('auth.nameLabel'),
                    hint: strings.t('auth.nameHint'),
                    icon: Icons.person_outline,
                    controller: _name,
                    uppercaseLabel: true,
                    labelColor: AppColors.textSecondary,
                    errorText: _nameError,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: strings.t('auth.emailLabel'),
                    hint: strings.t('auth.emailHint'),
                    icon: Icons.mail_outline,
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    uppercaseLabel: true,
                    labelColor: AppColors.textSecondary,
                    errorText: _emailError,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: strings.t('auth.phoneLabel'),
                    hint: strings.t('auth.phoneHint'),
                    icon: Icons.phone_outlined,
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    uppercaseLabel: true,
                    labelColor: AppColors.textSecondary,
                    errorText: _phoneError,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: strings.t('auth.passwordLabel'),
                    hint: strings.t('auth.passwordHint'),
                    icon: Icons.lock_outline,
                    controller: _password,
                    obscure: _obscure,
                    uppercaseLabel: true,
                    labelColor: AppColors.textSecondary,
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
                  const SizedBox(height: 16),
                  AppTextField(
                    label:
                        '${strings.t('auth.addressLabel')} '
                        '(${strings.t('auth.addressOptional')})',
                    hint: strings.t('auth.addressHint'),
                    icon: Icons.place_outlined,
                    controller: _address,
                    uppercaseLabel: true,
                    labelColor: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  _TermsRow(
                    checked: _acceptedTerms,
                    hasError: _termsError,
                    template: strings.t('auth.termsAgreement'),
                    terms: strings.t('auth.terms'),
                    privacy: strings.t('auth.privacy'),
                    onChanged: (value) => setState(() {
                      _acceptedTerms = value;
                      if (value) _termsError = false;
                    }),
                  ),
                  if (_termsError)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 8),
                      child: Text(
                        strings.t('auth.errorTerms'),
                        style: AppTextStyles.label.copyWith(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 16),
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
                          Flexible(
                            child: Text(
                              strings.t('auth.createAccount'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.buttonLarge,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      Text(
                        strings.t('auth.haveAccount'),
                        style: AppTextStyles.bodySmall,
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.login),
                        child: Text(
                          strings.t('auth.login'),
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Чекбокс согласия: текст собирается из шаблона с {terms} и {privacy},
/// чтобы порядок слов не ломался при переводе.
class _TermsRow extends StatelessWidget {
  const _TermsRow({
    required this.checked,
    required this.hasError,
    required this.template,
    required this.terms,
    required this.privacy,
    required this.onChanged,
  });

  final bool checked;
  final bool hasError;
  final String template;
  final String terms;
  final String privacy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final linkStyle = AppTextStyles.bodySmall.copyWith(
      color: AppColors.primary,
    );

    final spans = <InlineSpan>[];
    var rest = template;
    while (rest.isNotEmpty) {
      final termsAt = rest.indexOf('{terms}');
      final privacyAt = rest.indexOf('{privacy}');
      final hasTerms = termsAt >= 0;
      final hasPrivacy = privacyAt >= 0;

      if (!hasTerms && !hasPrivacy) {
        spans.add(TextSpan(text: rest));
        break;
      }

      final isTerms = hasTerms && (!hasPrivacy || termsAt < privacyAt);
      final at = isTerms ? termsAt : privacyAt;
      final token = isTerms ? '{terms}' : '{privacy}';

      if (at > 0) spans.add(TextSpan(text: rest.substring(0, at)));
      spans.add(TextSpan(text: isTerms ? terms : privacy, style: linkStyle));
      rest = rest.substring(at + token.length);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: checked,
            onChanged: (value) => onChanged(value ?? false),
            side: BorderSide(color: hasError ? Colors.red : AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.checkbox),
            ),
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!checked),
            child: Text.rich(
              TextSpan(style: AppTextStyles.bodySmall, children: spans),
            ),
          ),
        ),
      ],
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/locale_providers.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/review_api.dart';
import 'review_stars.dart';

/// Форма отзыва. Открывается снизу, как и остальные шторки приложения.
class ReviewSheet extends ConsumerStatefulWidget {
  const ReviewSheet({required this.productSlug, super.key});

  final String productSlug;

  /// Возвращает true, если отзыв отправлен — карточку тогда перезапрашиваем.
  static Future<bool> show(BuildContext context, {required String slug}) async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
      ),
      builder: (_) => ReviewSheet(productSlug: slug),
    );

    return sent ?? false;
  }

  @override
  ConsumerState<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<ReviewSheet> {
  final _name = TextEditingController();
  final _comment = TextEditingController();
  final _advantages = TextEditingController();
  final _disadvantages = TextEditingController();

  int _rating = 0;
  bool _busy = false;
  String? _nameError;
  String? _commentError;
  String? _ratingError;

  @override
  void initState() {
    super.initState();

    // Вошедшему имя подставляем — переписывать его незачем.
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user != null) _name.text = user.name;
  }

  @override
  void dispose() {
    _name.dispose();
    _comment.dispose();
    _advantages.dispose();
    _disadvantages.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final strings = ref.read(stringsProvider);

    setState(() {
      _nameError = _name.text.trim().isEmpty
          ? strings.t('reviews.errorName')
          : null;
      // Тот же минимум, что и на сервере: короче десяти символов не примет.
      _commentError = _comment.text.trim().length < 10
          ? strings.t('reviews.errorComment')
          : null;
      _ratingError = _rating == 0 ? strings.t('reviews.errorRating') : null;
    });

    if (_nameError != null || _commentError != null || _ratingError != null) {
      return;
    }

    setState(() => _busy = true);

    try {
      await ReviewApi(ref.read(apiClientProvider)).submit(
        productSlug: widget.productSlug,
        name: _name.text.trim(),
        rating: _rating,
        comment: _comment.text.trim(),
        advantages: _advantages.text.trim().isEmpty
            ? null
            : _advantages.text.trim(),
        disadvantages: _disadvantages.text.trim().isEmpty
            ? null
            : _disadvantages.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      final fields = error is ApiException
          ? {
              'name': error.errorFor('name'),
              'comment': error.errorFor('comment'),
              'rating': error.errorFor('rating'),
            }
          : const <String, String?>{};

      setState(() {
        _busy = false;
        _nameError = fields['name'];
        _commentError = fields['comment'];
        _ratingError = fields['rating'];
      });

      // Общая ошибка — не про конкретное поле: недоступный сервер, отсутствующий
      // маршрут, обрыв связи. Под полем отзыва она читалась бы как претензия
      // к тексту, поэтому показываем отдельно.
      if (fields.values.every((message) => message == null)) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('$error'),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.strings;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        // Форма длинная: поднимаем её над клавиатурой.
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.t('reviews.formTitle'),
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            Text(
              strings.t('reviews.ratingLabel'),
              style: AppTextStyles.label.copyWith(
                color: _ratingError == null
                    ? AppColors.textPrimary
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            ReviewStars(
              rating: _rating.toDouble(),
              size: 32,
              onRate: (value) => setState(() {
                _rating = value;
                _ratingError = null;
              }),
            ),
            if (_ratingError != null) ...[
              const SizedBox(height: 4),
              Text(
                _ratingError!,
                style: AppTextStyles.label.copyWith(color: Colors.red),
              ),
            ],
            const SizedBox(height: 20),
            AppTextField(
              label: strings.t('reviews.nameLabel'),
              hint: strings.t('reviews.nameHint'),
              icon: Icons.person_outline,
              controller: _name,
              errorText: _nameError,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: strings.t('reviews.commentLabel'),
              hint: strings.t('reviews.commentHint'),
              icon: Icons.chat_bubble_outline,
              controller: _comment,
              errorText: _commentError,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: strings.t('reviews.prosLabel'),
              hint: strings.t('reviews.optional'),
              icon: Icons.add_circle_outline,
              controller: _advantages,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: strings.t('reviews.consLabel'),
              hint: strings.t('reviews.optional'),
              icon: Icons.remove_circle_outline,
              controller: _disadvantages,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _busy ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.control),
                  ),
                ),
                child: Text(
                  strings.t('reviews.submit'),
                  style: AppTextStyles.label.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

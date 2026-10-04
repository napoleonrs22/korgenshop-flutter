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
import '../../data/datasources/lead_api.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/quiz_estimate.dart';

/// Форма заявки по итогам квиза.
class LeadSheet extends ConsumerStatefulWidget {
  const LeadSheet({
    required this.quiz,
    required this.estimate,
    required this.answers,
    required this.photos,
    super.key,
  });

  final Quiz quiz;
  final QuizEstimate estimate;
  final Map<String, QuizOption> answers;

  /// Снимки объекта с шага квиза — уходят в заявку вложениями.
  final List<String> photos;

  static Future<void> show(
    BuildContext context, {
    required Quiz quiz,
    required QuizEstimate estimate,
    required Map<String, QuizOption> answers,
    required List<String> photos,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.card),
        ),
      ),
      builder: (_) => LeadSheet(
        quiz: quiz,
        estimate: estimate,
        answers: answers,
        photos: photos,
      ),
    );
  }

  @override
  ConsumerState<LeadSheet> createState() => _LeadSheetState();
}

class _LeadSheetState extends ConsumerState<LeadSheet> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  String? _nameError;
  String? _phoneError;
  String? _addressError;
  bool _busy = false;

  @override
  void initState() {
    super.initState();

    final user = ref.read(authControllerProvider).valueOrNull;
    if (user != null) {
      _name.text = user.name;
      _phone.text = user.phone;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final strings = ref.read(stringsProvider);
    final required = strings.t('quiz.leadRequired');

    setState(() {
      _nameError = _name.text.trim().isEmpty ? required : null;
      _phoneError = _phone.text.trim().isEmpty ? required : null;
      _addressError = _address.text.trim().isEmpty ? required : null;
    });

    if (_nameError != null || _phoneError != null || _addressError != null) {
      return;
    }

    setState(() => _busy = true);

    try {
      final id = await LeadApiDataSource(ref.read(apiClientProvider)).submit(
        quiz: widget.quiz,
        estimate: widget.estimate,
        answers: widget.answers,
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        photos: widget.photos,
      );

      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(strings.t('quiz.leadSuccess', params: {'id': id})),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _nameError = error.errorFor('name') ?? _nameError;
        _phoneError = error.errorFor('phone') ?? _phoneError;
        _addressError = error.errorFor('address') ?? _addressError;
        _busy = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.t('quiz.leadTitle'),
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(strings.t('quiz.leadSubtitle'), style: AppTextStyles.bodySmall),
          const SizedBox(height: 20),
          AppTextField(
            label: strings.t('quiz.leadName'),
            hint: strings.t('quiz.leadNameHint'),
            icon: Icons.person_outline,
            controller: _name,
            errorText: _nameError,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: strings.t('quiz.leadPhone'),
            hint: strings.t('quiz.leadPhoneHint'),
            icon: Icons.phone_outlined,
            controller: _phone,
            keyboardType: TextInputType.phone,
            errorText: _phoneError,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: strings.t('quiz.leadAddress'),
            hint: strings.t('quiz.leadAddressHint'),
            icon: Icons.location_on_outlined,
            controller: _address,
            errorText: _addressError,
          ),
          const SizedBox(height: 20),
          SizedBox(
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
                strings.t('quiz.leadSubmit'),
                style: AppTextStyles.buttonLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

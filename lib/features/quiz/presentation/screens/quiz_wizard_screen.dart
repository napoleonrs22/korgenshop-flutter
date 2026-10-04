import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/entities/quiz.dart';
import '../providers/quiz_providers.dart';
import '../widgets/option_grid.dart';
import '../widgets/photo_step.dart';
import '../widgets/quiz_progress.dart';
import '../widgets/quiz_result.dart';
import '../../../../core/l10n/locale_providers.dart';
import '../widgets/lead_sheet.dart';

class QuizWizardScreen extends ConsumerWidget {
  const QuizWizardScreen({required this.quizId, super.key});

  final String quizId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quiz = ref.watch(quizByIdProvider(quizId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        compactLogo: true,
        showBackButton: true,
        onLeadingTap: () => context.go(AppRoutes.quizzes),
        onActionTap: () => context.go(AppRoutes.catalog),
      ),
      body: quiz.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(ref.strings.t('common.error', params: {'error': error})),
        ),
        data: (item) {
          if (item == null) {
            return Center(
              child: Text(
                ref.strings.t('quiz.notFound'),
                style: AppTextStyles.body,
              ),
            );
          }
          return _WizardBody(quiz: item);
        },
      ),
    );
  }
}

class _WizardBody extends ConsumerWidget {
  const _WizardBody({required this.quiz});

  final Quiz quiz;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizWizardProvider(quiz));
    final notifier = ref.read(quizWizardProvider(quiz).notifier);
    final step = state.step;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        QuizProgress(
          stepLabel: ref.strings.t(
            'quiz.stepOf',
            params: {
              'current': state.currentStep + 1,
              'total': quiz.totalSteps,
            },
          ),
          quizTitle: quiz.shortTitle,
          progress: state.progress,
        ),
        const SizedBox(height: 24),
        SurfaceCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (step != null) ...[
                Text(
                  step.question,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                OptionGrid(
                  options: step.options,
                  selected: state.currentAnswer,
                  onSelect: notifier.select,
                ),
              ] else if (state.isPhotoStep)
                PhotoStep(
                  strings: ref.strings,
                  photos: state.photos,
                  onAdd: notifier.addPhotos,
                  onRemove: notifier.removePhoto,
                )
              else
                QuizResult(estimate: notifier.estimate),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.only(top: 17),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: state.isResultStep
                    ? _ResultActions(
                        onRestart: notifier.reset,
                        onSendLead: () => LeadSheet.show(
                          context,
                          quiz: quiz,
                          estimate: notifier.estimate,
                          answers: state.answers,
                          photos: state.photos,
                        ),
                      )
                    : _StepActions(
                        showBack: !state.isFirstStep,
                        canGoNext: state.canGoNext,
                        onBack: notifier.back,
                        onNext: notifier.next,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepActions extends ConsumerWidget {
  const _StepActions({
    required this.showBack,
    required this.canGoNext,
    required this.onBack,
    required this.onNext,
  });

  final bool showBack;
  final bool canGoNext;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // На первом шаге место кнопки «Назад» остаётся пустым — как в макете.
        if (showBack)
          TextButton(
            onPressed: onBack,
            child: Text(
              strings.t('quiz.back'),
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
        _WizardButton(
          label: strings.t('quiz.next'),
          onPressed: canGoNext ? onNext : null,
        ),
      ],
    );
  }
}

class _ResultActions extends ConsumerWidget {
  const _ResultActions({required this.onRestart, required this.onSendLead});

  final VoidCallback onRestart;
  final VoidCallback onSendLead;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: onRestart,
          child: Text(
            ref.strings.t('quiz.startOver'),
            style: AppTextStyles.buttonMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        _WizardButton(
          label: ref.strings.t('quiz.leadTitle'),
          onPressed: onSendLead,
        ),
      ],
    );
  }
}

/// Синяя кнопка визарда: r2, 16/24, серая в неактивном состоянии.
class _WizardButton extends StatelessWidget {
  const _WizardButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Material(
      color: enabled ? AppColors.primary : AppColors.progressTrack,
      borderRadius: BorderRadius.circular(2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: AppTextStyles.buttonMedium.copyWith(
              color: enabled ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

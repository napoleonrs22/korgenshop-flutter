import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_menu_sheet.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../providers/quiz_providers.dart';
import '../widgets/quiz_tile.dart';
import '../../../../core/l10n/locale_providers.dart';

class QuizSelectionScreen extends ConsumerWidget {
  const QuizSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzes = ref.watch(quizzesProvider);

    final strings = ref.strings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        onLeadingTap: () => AppMenuSheet.show(context),
        onActionTap: () => context.go(AppRoutes.catalog),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
        children: [
          Text(
            strings.t('quiz.title'),
            style: AppTextStyles.h2.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(strings.t('quiz.subtitle'), style: AppTextStyles.body),
          const SizedBox(height: 24),
          quizzes.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) =>
                Text(strings.t('quiz.error', params: {'error': error})),
            data: (items) => Column(
              children: [
                for (final quiz in items) ...[
                  QuizTile(
                    quiz: quiz,
                    onTap: () => context.go(AppRoutes.quiz(quiz.id)),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

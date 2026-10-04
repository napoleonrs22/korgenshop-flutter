import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../../domain/services/quiz_estimator.dart';
import '../state/quiz_wizard_state.dart';
import '../../data/repositories/quiz_repository_impl.dart';
import '../../data/datasources/quiz_mock.dart';
import '../../../../core/l10n/locale_providers.dart';

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => QuizRepositoryImpl(QuizMockDataSource(ref.watch(stringsProvider))),
);

final quizzesProvider = FutureProvider<List<Quiz>>(
  (ref) => ref.watch(quizRepositoryProvider).getQuizzes(),
);

final quizByIdProvider = FutureProvider.family<Quiz?, String>(
  (ref, id) => ref.watch(quizRepositoryProvider).getQuizById(id),
);

/// Состояние визарда для конкретного квиза.
///
/// `autoDispose` сбрасывает ответы, когда экран визарда закрывают.
final quizWizardProvider = StateNotifierProvider.autoDispose
    .family<QuizWizardNotifier, QuizWizardState, Quiz>(
      (ref, quiz) => QuizWizardNotifier(quiz, getIt<QuizEstimator>()),
    );

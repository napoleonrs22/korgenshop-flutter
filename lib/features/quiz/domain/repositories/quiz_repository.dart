import '../entities/quiz.dart';

abstract class QuizRepository {
  Future<List<Quiz>> getQuizzes();

  Future<Quiz?> getQuizById(String id);
}

import '../../domain/entities/quiz.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../datasources/quiz_mock.dart';

class QuizRepositoryImpl implements QuizRepository {
  const QuizRepositoryImpl(this._dataSource);

  final QuizMockDataSource _dataSource;

  @override
  Future<List<Quiz>> getQuizzes() => _dataSource.fetchQuizzes();

  @override
  Future<Quiz?> getQuizById(String id) => _dataSource.fetchQuizById(id);
}

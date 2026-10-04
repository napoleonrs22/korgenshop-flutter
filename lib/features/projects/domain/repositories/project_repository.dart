import '../entities/project.dart';

abstract class ProjectRepository {
  /// Полный список для экрана «Реализованные проекты».
  Future<List<Project>> getProjects();

  /// Подборка для карусели на главной.
  Future<List<Project>> getFeaturedProjects();
}

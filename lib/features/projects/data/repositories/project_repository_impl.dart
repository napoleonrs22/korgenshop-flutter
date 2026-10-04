import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_api.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  const ProjectRepositoryImpl(this._dataSource);

  final ProjectApiDataSource _dataSource;

  @override
  Future<List<Project>> getProjects() => _dataSource.fetchProjects();

  @override
  Future<List<Project>> getFeaturedProjects() =>
      _dataSource.fetchFeaturedProjects();
}

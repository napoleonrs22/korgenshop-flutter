import '../../../../core/network/api_client.dart';
import '../../domain/entities/project.dart';

/// Проекты из GET /projects.
class ProjectApiDataSource {
  const ProjectApiDataSource(this._api);

  final ApiClient _api;

  Future<List<Project>> fetchProjects() async {
    final data = await _api.get('/projects');
    final items = (data as Map)['data'] as List<dynamic>? ?? const [];

    return items.map((item) {
      final json = item as Map<String, dynamic>;
      final image = '${json['cover_image'] ?? json['panel_image'] ?? ''}';

      return Project(
        id: '${json['slug'] ?? json['id']}',
        title: '${json['title'] ?? ''}',
        description: '${json['description'] ?? json['subtitle'] ?? ''}',
        image: image.isEmpty ? null : image,
        category: _nullable(json['badge']),
        client: _nullable(json['subtitle']),
      );
    }).toList();
  }

  /// Карусель на главной показывает первые три проекта.
  Future<List<Project>> fetchFeaturedProjects() async {
    final projects = await fetchProjects();
    return projects.take(3).toList();
  }

  String? _nullable(dynamic value) {
    final text = '${value ?? ''}'.trim();
    return text.isEmpty ? null : text;
  }
}

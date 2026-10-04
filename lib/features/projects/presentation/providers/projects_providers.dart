import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../data/datasources/project_api.dart';
import '../../../../core/network/network_providers.dart';

final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) =>
      ProjectRepositoryImpl(ProjectApiDataSource(ref.watch(apiClientProvider))),
);

final projectsProvider = FutureProvider<List<Project>>(
  (ref) => ref.watch(projectRepositoryProvider).getProjects(),
);

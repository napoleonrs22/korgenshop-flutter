import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/support_info.dart';
import '../../domain/repositories/support_repository.dart';
import '../../data/repositories/support_repository_impl.dart';
import '../../data/datasources/support_mock.dart';
import '../../../../core/l10n/locale_providers.dart';

final supportRepositoryProvider = Provider<SupportRepository>(
  (ref) =>
      SupportRepositoryImpl(SupportMockDataSource(ref.watch(stringsProvider))),
);

final contactInfoProvider = FutureProvider<ContactInfo>(
  (ref) => ref.watch(supportRepositoryProvider).getContactInfo(),
);

final faqProvider = FutureProvider<List<FaqItem>>(
  (ref) => ref.watch(supportRepositoryProvider).getFaq(),
);

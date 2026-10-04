import '../../domain/entities/support_info.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_mock.dart';

class SupportRepositoryImpl implements SupportRepository {
  const SupportRepositoryImpl(this._dataSource);

  final SupportMockDataSource _dataSource;

  @override
  Future<ContactInfo> getContactInfo() => _dataSource.fetchContactInfo();

  @override
  Future<List<FaqItem>> getFaq() => _dataSource.fetchFaq();
}

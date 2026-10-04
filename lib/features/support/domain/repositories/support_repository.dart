import '../entities/support_info.dart';

abstract class SupportRepository {
  Future<ContactInfo> getContactInfo();

  Future<List<FaqItem>> getFaq();
}

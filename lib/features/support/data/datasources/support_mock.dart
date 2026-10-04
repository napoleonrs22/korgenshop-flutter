import '../../../../core/l10n/app_strings.dart';
import '../../domain/entities/support_info.dart';

/// Контакты и FAQ — целиком из словаря локали.
class SupportMockDataSource {
  const SupportMockDataSource(this._strings);

  final AppStrings _strings;

  static const _latency = Duration(milliseconds: 150);

  Future<ContactInfo> fetchContactInfo() async {
    await Future<void>.delayed(_latency);
    return ContactInfo(
      officeTitle: _strings.t('content.support.office.officeTitle'),
      company: _strings.t('content.support.office.company'),
      addressLines: _strings.list('content.support.office.addressLines'),
      phoneTitle: _strings.t('content.support.office.phoneTitle'),
      phone: _strings.t('content.support.office.phone'),
      workingHours: _strings.t('content.support.office.workingHours'),
    );
  }

  Future<List<FaqItem>> fetchFaq() async {
    await Future<void>.delayed(_latency);
    return [
      for (final id in _strings.keys('content.support.faq'))
        FaqItem(
          question: _strings.t('content.support.faq.$id.question'),
          answer: _strings.t('content.support.faq.$id.answer'),
        ),
    ];
  }
}

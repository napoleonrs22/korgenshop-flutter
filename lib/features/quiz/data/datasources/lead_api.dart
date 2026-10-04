import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/quiz_estimate.dart';
import '../../../../core/utils/money.dart';

/// Заявка по итогам квиза: POST /leads.
///
/// Значения `type` на бэкенде — `cctv` и `access`, они совпадают с
/// идентификаторами квизов в приложении.
class LeadApiDataSource {
  const LeadApiDataSource(this._api);

  final ApiClient _api;

  Future<int> submit({
    required Quiz quiz,
    required QuizEstimate estimate,
    required Map<String, QuizOption> answers,
    required String name,
    required String phone,
    required String address,
    List<String> photos = const [],
  }) async {
    final fields = <String, dynamic>{
      'type': quiz.id,
      // На сайте это «Направление» — выбор из списка проектов. У квиза
      // направление задано им самим, поэтому берём его название.
      'project_name': quiz.title,
      'name': name,
      'phone': phone,
      'address': address,
      // Первый ответ описывает объект. Пустым он не бывает, но поле на
      // бэкенде обязательное, поэтому держим запасное значение.
      'object_type': answers.values.isEmpty
          ? quiz.title
          : answers.values.first.label,
      'service': quiz.shortTitle,
      'quantity': '${estimate.unitCount} ${estimate.unitLabel}',
      'comment': _comment(estimate, answers),
    };

    // Без снимков шлём обычный JSON: так проще и логам, и отладке.
    // Со снимками — multipart, поле `files[]`, как ждёт бэкенд.
    final data = await _api.post(
      '/leads',
      body: photos.isEmpty ? fields : await _multipart(fields, photos),
    );

    return ((data as Map)['id'] as num?)?.toInt() ?? 0;
  }

  Future<FormData> _multipart(
    Map<String, dynamic> fields,
    List<String> photos,
  ) async {
    final form = FormData();

    fields.forEach((key, value) {
      if (value != null) form.fields.add(MapEntry(key, '$value'));
    });

    for (final path in photos) {
      form.files.add(
        MapEntry('files[]', await MultipartFile.fromFile(path)),
      );
    }

    return form;
  }

  /// В комментарий кладём ответы и смету — оператору этого достаточно,
  /// чтобы перезвонить по делу.
  String _comment(QuizEstimate estimate, Map<String, QuizOption> answers) {
    final lines = [
      for (final answer in answers.values) '— ${answer.label}',
      'Предварительно: ${Money.format(estimate.total)}',
    ];

    return lines.join('\n');
  }
}

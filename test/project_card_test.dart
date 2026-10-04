import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app/core/widgets/badges.dart';
import 'package:test_app/features/home/presentation/widgets/featured_project_card.dart';
import 'package:test_app/features/projects/domain/entities/project.dart';

/// Карточка проекта живёт в карусели фиксированной высоты (304), поэтому
/// длинная подпись клиента не должна переноситься на вторую строку —
/// иначе содержимое выдавливается за нижний край.
///
/// Проверка структурная, а не по высоте: подставной шрифт в тестах не
/// содержит кириллицы, метрики не совпадают с устройством, и переполнение
/// на реальном телефоне здесь не воспроизводится.
void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('длинная подпись клиента не переносится', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 304,
            child: FeaturedProjectCard(
              project: const Project(
                id: 'korgen-control',
                title: 'Korgen Control',
                description: 'Распознавание номеров и автоматический шлагбаум',
                image: null,
                client: 'Распознавание номеров и автоматический шлагбаум',
              ),
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    final badge = tester.widget<Text>(
      find
          .descendant(of: find.byType(LabelBadge), matching: find.byType(Text))
          .first,
    );

    expect(badge.maxLines, 1);
    expect(badge.overflow, TextOverflow.ellipsis);
  });
}

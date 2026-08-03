import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_mobile/utils/date_format_fr.dart';

void main() {
  group('formatDayLabel', () {
    test('formate jour + mois abrégé en minuscules', () {
      expect(formatDayLabel(DateTime(2026, 7, 15)), '15 juil.');
      expect(formatDayLabel(DateTime(2026, 1, 1)), '1 janv.');
      expect(formatDayLabel(DateTime(2026, 12, 25)), '25 déc.');
      expect(formatDayLabel(DateTime(2026, 8, 3)), '3 août');
    });
  });

  group('formatWeekdayLabel', () {
    test('formate le jour de la semaine en majuscules', () {
      expect(formatWeekdayLabel(DateTime(2026, 7, 15)), 'MERCREDI');
      expect(formatWeekdayLabel(DateTime(2026, 1, 1)), 'JEUDI');
      expect(formatWeekdayLabel(DateTime(2026, 12, 25)), 'VENDREDI');
      expect(formatWeekdayLabel(DateTime(2026, 8, 3)), 'LUNDI');
    });
  });
}

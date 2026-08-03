/// Logique métier pure de TimeFlow (règles RG-01..RG-08, stats, durées).
/// Dart pur, dépend uniquement de `timeflow_domain`.
library timeflow_core;

export 'src/activities/close_activity.dart';
export 'src/activities/create_activity.dart';
export 'src/activities/duration.dart';
export 'src/activities/validate_activity.dart';
export 'src/constants/categories.dart';
export 'src/stats/aggregate_range.dart';
export 'src/stats/compute_day_stats.dart';
export 'src/stats/productivity_score.dart';

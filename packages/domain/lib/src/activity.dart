/// Catégories d'activités disponibles dans TimeFlow.
///
/// Ces 8 valeurs sont fixes pour le MVP (voir `.claude/docs/data-model.md`).
/// `work`, `study` et `side_project` sont les catégories productives au sens
/// de RG-06 (voir `packages/core/lib/src/constants/categories.dart`).
enum CategoryId {
  work,
  study,
  side_project,
  sport,
  leisure,
  sleep,
  social,
  other,
}

/// Sentinelle utilisée par [Activity.copyWith] pour distinguer
/// « ne pas changer ce champ » de « remettre ce champ à `null` ».
const Object _unset = Object();

/// Une activité suivie par l'utilisateur.
///
/// Immuable : toute modification passe par [copyWith].
///
/// - RG-01 : [title] et [category] sont obligatoires (non nullables).
/// - RG-03 : [endTime] (et donc [durationMin]) peuvent être `null` — activité
///   en cours.
/// - RG-04 : [durationMin] est dérivée de [startTime]/[endTime] (voir
///   `packages/core`), jamais recalculée dans l'UI.
/// - RG-05 : [date] (`YYYY-MM-DD`, heure locale) sert de clé d'agrégation
///   journalière.
class Activity {
  const Activity({
    required this.id,
    required this.title,
    required this.category,
    required this.startTime,
    required this.date,
    required this.createdAt,
    this.endTime,
    this.durationMin,
  });

  /// Identifiant unique (UUID v4).
  final String id;

  /// Titre de l'activité — obligatoire (RG-01).
  final String title;

  /// Catégorie de l'activité — obligatoire (RG-01).
  final CategoryId category;

  /// Heure de début, ISO 8601 locale.
  final DateTime startTime;

  /// Heure de fin, ISO 8601 locale. `null` si l'activité est en cours (RG-03).
  final DateTime? endTime;

  /// Durée en minutes, arrondie. `null` si l'activité est en cours (RG-03/04).
  final int? durationMin;

  /// Jour d'appartenance de l'activité, `YYYY-MM-DD`, dérivé de [startTime]
  /// en heure locale (RG-05).
  final String date;

  /// Date de création de l'enregistrement, ISO 8601 locale.
  final DateTime createdAt;

  /// `true` si l'activité n'a pas encore été clôturée (RG-03).
  bool get isInProgress => endTime == null;

  Activity copyWith({
    String? id,
    String? title,
    CategoryId? category,
    DateTime? startTime,
    Object? endTime = _unset,
    Object? durationMin = _unset,
    String? date,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      endTime: identical(endTime, _unset) ? this.endTime : endTime as DateTime?,
      durationMin: identical(durationMin, _unset)
          ? this.durationMin
          : durationMin as int?,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Activity &&
        other.id == id &&
        other.title == title &&
        other.category == category &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.durationMin == durationMin &&
        other.date == date &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        category,
        startTime,
        endTime,
        durationMin,
        date,
        createdAt,
      );

  @override
  String toString() =>
      'Activity(id: $id, title: $title, category: $category, '
      'startTime: $startTime, endTime: $endTime, durationMin: $durationMin, '
      'date: $date, createdAt: $createdAt)';
}

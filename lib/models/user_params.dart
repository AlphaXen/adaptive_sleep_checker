class UserParams {
  double tSleep;
  double cafWindow;
  int winddownMinutes;
  double chronoOffset;
  double lightSens;
  double cafSens;
  int dayStartHour; // 하루 시작 시각 (0~23, 야간 노동자용 커스텀)

  UserParams({
    this.tSleep = 7.0,
    this.cafWindow = 6.0,
    this.winddownMinutes = 60,
    this.chronoOffset = 0.0,
    this.lightSens = 0.5,
    this.cafSens = 0.5,
    this.dayStartHour = 15, // 기본: 오후 3시 기준 하루
  });

  Map<String, dynamic> toMap() => {
        'tSleep': tSleep,
        'cafWindow': cafWindow,
        'winddownMinutes': winddownMinutes,
        'chronoOffset': chronoOffset,
        'lightSens': lightSens,
        'cafSens': cafSens,
        'dayStartHour': dayStartHour,
      };

  static UserParams fromMap(Map<String, dynamic> map) => UserParams(
        tSleep: (map['tSleep'] as num?)?.toDouble() ?? 7.0,
        cafWindow: (map['cafWindow'] as num?)?.toDouble() ?? 6.0,
        winddownMinutes: (map['winddownMinutes'] as int?) ?? 60,
        chronoOffset: (map['chronoOffset'] as num?)?.toDouble() ?? 0.0,
        lightSens: (map['lightSens'] as num?)?.toDouble() ?? 0.5,
        cafSens: (map['cafSens'] as num?)?.toDouble() ?? 0.5,
        dayStartHour: (map['dayStartHour'] as int?) ?? 15,
      );

  UserParams copyWith({
    double? tSleep,
    double? cafWindow,
    int? winddownMinutes,
    double? chronoOffset,
    double? lightSens,
    double? cafSens,
    int? dayStartHour,
  }) {
    return UserParams(
      tSleep: tSleep ?? this.tSleep,
      cafWindow: cafWindow ?? this.cafWindow,
      winddownMinutes: winddownMinutes ?? this.winddownMinutes,
      chronoOffset: chronoOffset ?? this.chronoOffset,
      lightSens: lightSens ?? this.lightSens,
      cafSens: cafSens ?? this.cafSens,
      dayStartHour: dayStartHour ?? this.dayStartHour,
    );
  }
}

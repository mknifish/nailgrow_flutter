class Progress {
  int targetDays;
  int achievedDays;

  Progress({
    required this.targetDays,
    required this.achievedDays,
  });

  double get progress {
    return targetDays > 0 ? achievedDays / targetDays : 0.0;
  }
}

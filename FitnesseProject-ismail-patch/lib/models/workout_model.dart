class WorkoutModel {
  final String id;
  final String name;
  final String type;
  final int duration; // in minutes
  final DateTime date;

  WorkoutModel({
    required this.id,
    required this.name,
    required this.type,
    required this.duration,
    required this.date,
  });
} 
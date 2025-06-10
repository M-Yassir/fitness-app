import 'package:flutter/material.dart';
import '../models/workout_model.dart';

class WorkoutProvider extends ChangeNotifier {
  final List<WorkoutModel> _workouts = [];
  List<WorkoutModel> get workouts => List.unmodifiable(_workouts);

  void addWorkout(WorkoutModel workout) {
    _workouts.add(workout);
    notifyListeners();
  }

  void updateWorkout(String id, WorkoutModel updated) {
    final index = _workouts.indexWhere((w) => w.id == id);
    if (index != -1) {
      _workouts[index] = updated;
      notifyListeners();
    }
  }

  void deleteWorkout(String id) {
    _workouts.removeWhere((w) => w.id == id);
    notifyListeners();
  }
} 
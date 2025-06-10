import 'package:flutter/material.dart';
import '../models/meal_model.dart';

class MealProvider extends ChangeNotifier {
  final List<MealModel> _meals = [];
  List<MealModel> get meals => List.unmodifiable(_meals);

  void addMeal(MealModel meal) {
    _meals.add(meal);
    notifyListeners();
  }

  void updateMeal(String id, MealModel updated) {
    final index = _meals.indexWhere((m) => m.id == id);
    if (index != -1) {
      _meals[index] = updated;
      notifyListeners();
    }
  }

  void deleteMeal(String id) {
    _meals.removeWhere((m) => m.id == id);
    notifyListeners();
  }
} 
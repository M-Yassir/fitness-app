import 'package:flutter/foundation.dart';
import '../models/meal_model.dart';
import '../services/meal_api_service.dart';

class MealApiProvider with ChangeNotifier {
  final MealApiService _apiService = MealApiService();
  List<MealModel> _weeklyMeals = [];
  bool _isLoading = false;
  String? _error;

  List<MealModel> get weeklyMeals => _weeklyMeals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeeklyMealPlan({int count = 7}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _weeklyMeals = await _apiService.getRandomMeals(count: count);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearMeals() {
    _weeklyMeals = [];
    _error = null;
    notifyListeners();
  }
} 
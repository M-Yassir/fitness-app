import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_model.dart';

class MealApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Obtenir un repas aléatoire
  Future<List<MealModel>> getRandomMeals({int count = 7}) async {
    List<MealModel> meals = [];
    for (int i = 0; i < count; i++) {
      final response = await http.get(Uri.parse('$baseUrl/random.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          meals.add(MealModel.fromMealDbJson(data['meals'][0]));
        }
      } else {
        throw Exception('Erreur lors de la récupération des repas');
      }
    }
    return meals;
  }

  // Chercher des repas par ingrédient
  Future<List<MealModel>> searchMealsByIngredient(String ingredient) async {
    final response = await http.get(Uri.parse('$baseUrl/filter.php?i=$ingredient'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null) {
        return List<MealModel>.from(
          data['meals'].map((meal) => MealModel.fromMealDbJson(meal)),
        );
      } else {
        return [];
      }
    } else {
      throw Exception('Erreur lors de la recherche de repas');
    }
  }
} 
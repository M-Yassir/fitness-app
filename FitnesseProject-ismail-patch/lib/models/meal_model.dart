class MealModel {
  final String id;
  final String mealName;
  final int calories;
  final String macros; // e.g. "P:20g, C:30g, F:10g"
  final DateTime time;
  final String? imageUrl;
  final String? recipeUrl;
  final int? preparationTime;
  final int? servings;
  

  MealModel({
    required this.id,
    required this.mealName,
    required this.calories,
    required this.macros,
    required this.time,
    this.imageUrl,
    this.recipeUrl,
    this.preparationTime,
    this.servings,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'].toString(),
      mealName: json['title'] ?? '',
      calories: json['calories'] is int
          ? json['calories']
          : int.tryParse(json['calories']?.toString() ?? '') ?? 0,
      macros: 'P:${json['protein'] ?? 0}g, C:${json['carbs'] ?? 0}g, F:${json['fat'] ?? 0}g',
      time: DateTime.now(),
      imageUrl: json['image'],
      recipeUrl: json['sourceUrl'],
      preparationTime: json['readyInMinutes'] is int
          ? json['readyInMinutes']
          : int.tryParse(json['readyInMinutes']?.toString() ?? ''),
      servings: json['servings'] is int
          ? json['servings']
          : int.tryParse(json['servings']?.toString() ?? ''),
    );
  }

  factory MealModel.fromMealDbJson(Map<String, dynamic> json) {
    String? source = json['strSource'];
    String? youtube = json['strYoutube'];
    String? recipeUrl;
    if (source != null && source.isNotEmpty && source.startsWith('http')) {
      recipeUrl = source;
    } else if (youtube != null && youtube.isNotEmpty && youtube.startsWith('http')) {
      recipeUrl = youtube;
    } else {
      recipeUrl = null;
    }
    return MealModel(
      id: json['idMeal'] ?? '',
      mealName: json['strMeal'] ?? '',
      calories: 0, // TheMealDB ne fournit pas les calories
      macros: '', // TheMealDB ne fournit pas les macros
      time: DateTime.now(),
      imageUrl: json['strMealThumb'],
      recipeUrl: recipeUrl,
      preparationTime: null, // Non fourni
      servings: null, // Non fourni
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': mealName,
      'calories': calories,
      'macros': macros,
      'date': time.toIso8601String(),
      'image': imageUrl,
      'sourceUrl': recipeUrl,
      'readyInMinutes': preparationTime,
      'servings': servings,
    };
  }
} 
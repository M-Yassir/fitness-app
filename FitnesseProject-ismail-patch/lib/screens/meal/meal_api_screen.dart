import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/meal_api_provider.dart';
import '../../models/meal_model.dart';

class MealApiScreen extends StatefulWidget {
  const MealApiScreen({Key? key}) : super(key: key);

  @override
  State<MealApiScreen> createState() => _MealApiScreenState();
}

class _MealApiScreenState extends State<MealApiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MealApiProvider>(context, listen: false).fetchWeeklyMealPlan(count: 7);
    });
  }

  Future<void> _launchRecipeUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le lien de la recette.')),
      );
    }
  }

  Widget _buildMealCard(MealModel meal) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meal.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(
                meal.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.mealName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if (meal.recipeUrl != null && meal.recipeUrl!.startsWith('http'))
                  ElevatedButton.icon(
                    onPressed: () {
                      _launchRecipeUrl(meal.recipeUrl!);
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Voir la recette'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                else
                  const Text(
                    'Aucune recette disponible',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan de repas aléatoire (TheMealDB)'),
        elevation: 0,
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<MealApiProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }
          if (provider.weeklyMeals.isEmpty) {
            return const Center(
              child: Text('Aucun repas trouvé. Réessayez plus tard.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchWeeklyMealPlan(count: 7);
            },
            child: ListView.builder(
              itemCount: provider.weeklyMeals.length,
              itemBuilder: (context, index) {
                return _buildMealCard(provider.weeklyMeals[index]);
              },
            ),
          );
        },
      ),
    );
  }
} 
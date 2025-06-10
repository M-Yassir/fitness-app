import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meal_model.dart';
import '../../providers/meal_provider.dart';
import 'package:uuid/uuid.dart';

class MealFormScreen extends StatefulWidget {
  const MealFormScreen({Key? key}) : super(key: key);

  @override
  State<MealFormScreen> createState() => _MealFormScreenState();
}

class _MealFormScreenState extends State<MealFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _mealName = '';
  int _calories = 0;
  String _macros = '';
  DateTime _time = DateTime.now();
  bool _isEdit = false;
  String? _id;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is MealModel) {
      _isEdit = true;
      _id = arg.id;
      _mealName = arg.mealName;
      _calories = arg.calories;
      _macros = arg.macros;
      _time = arg.time;
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final provider = Provider.of<MealProvider>(context, listen: false);
    final meal = MealModel(
      id: _id ?? const Uuid().v4(),
      mealName: _mealName,
      calories: _calories,
      macros: _macros,
      time: _time,
    );
    if (_isEdit) {
      provider.updateMeal(meal.id, meal);
    } else {
      provider.addMeal(meal);
    }
    Navigator.pop(context);
  }

  Widget _buildCustomTextField({
    required String label,
    required String? initialValue,
    required String? Function(String?)? validator,
    required void Function(String?)? onSaved,
    TextInputType? keyboardType,
    IconData? prefixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D3748),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: const Color(0xFF667EEA), size: 20)
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667EEA).withOpacity(0.1),
            const Color(0xFF764BA2).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.access_time, color: Colors.white, size: 20),
        ),
        title: const Text(
          'Heure du repas',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A5568),
          ),
        ),
        subtitle: Text(
          '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Icon(Icons.edit, color: Color(0xFF667EEA), size: 18),
        ),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_time),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF667EEA),
                    surface: Colors.white,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() => _time = DateTime(
                _time.year, _time.month, _time.day, picked.hour, picked.minute));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Modifier le repas' : 'Ajouter un repas',
          style: const TextStyle(
            color: Color(0xFF2D3748),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isEdit ? 'Modifier le repas' : 'Nouveau repas',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/meal_api');
                          },
                          icon: const Icon(Icons.restaurant_menu),
                          label: const Text('Plan de repas API'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667EEA),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Informations du repas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildCustomTextField(
                      label: 'Nom du repas',
                      initialValue: _mealName,
                      prefixIcon: Icons.restaurant,
                      validator: (v) => v == null || v.isEmpty ? 'Entrez le nom du repas' : null,
                      onSaved: (v) => _mealName = v ?? '',
                    ),
                    _buildCustomTextField(
                      label: 'Calories',
                      initialValue: _calories == 0 ? '' : _calories.toString(),
                      prefixIcon: Icons.local_fire_department,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Entrez les calories' : null,
                      onSaved: (v) => _calories = int.tryParse(v ?? '') ?? 0,
                    ),
                    _buildCustomTextField(
                      label: 'Macros (ex: P:20g, C:30g, F:10g)',
                      initialValue: _macros,
                      prefixIcon: Icons.pie_chart,
                      validator: (v) => v == null || v.isEmpty ? 'Entrez les macros' : null,
                      onSaved: (v) => _macros = v ?? '',
                    ),
                    _buildTimeSelector(),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _save,
                    child: Center(
                      child: Text(
                        _isEdit ? 'Mettre à jour' : 'Ajouter le repas',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
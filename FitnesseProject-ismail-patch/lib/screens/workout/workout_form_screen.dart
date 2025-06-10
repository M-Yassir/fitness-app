import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/workout_model.dart';
import '../../providers/workout_provider.dart';
import 'package:uuid/uuid.dart';

class WorkoutFormScreen extends StatefulWidget {
  const WorkoutFormScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutFormScreen> createState() => _WorkoutFormScreenState();
}

class _WorkoutFormScreenState extends State<WorkoutFormScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _type = '';
  int _duration = 0;
  DateTime _date = DateTime.now();
  bool _isEdit = false;
  String? _id;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Liste prédéfinie des types d'entraînement avec des couleurs
  final Map<String, Map<String, dynamic>> _workoutTypes = {
    'Cardio': {'icon': Icons.favorite, 'color': Color(0xFFE74C3C)},
    'Musculation': {'icon': Icons.fitness_center, 'color': Color(0xFF3498DB)},
    'HIIT': {'icon': Icons.flash_on, 'color': Color(0xFFF39C12)},
    'Yoga': {'icon': Icons.self_improvement, 'color': Color(0xFF1ABC9C)},
    'Étirements': {'icon': Icons.accessibility_new, 'color': Color(0xFF9B59B6)},
    'Course': {'icon': Icons.directions_run, 'color': Color(0xFF27AE60)},
    'Natation': {'icon': Icons.pool, 'color': Color(0xFF17A2B8)},
    'Autre': {'icon': Icons.sports, 'color': Color(0xFF6C757D)},
  };
  
  String _selectedType = 'Cardio';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is WorkoutModel) {
      _isEdit = true;
      _id = arg.id;
      _name = arg.name;
      _type = arg.type;
      _selectedType = arg.type;
      _duration = arg.duration;
      _date = arg.date;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    // Animation de loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
              SizedBox(height: 16),
              Text('Enregistrement...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
    
    await Future.delayed(Duration(milliseconds: 500)); // Simulation
    
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    final workout = WorkoutModel(
      id: _id ?? const Uuid().v4(),
      name: _name,
      type: _selectedType,
      duration: _duration,
      date: _date,
    );
    
    if (_isEdit) {
      provider.updateWorkout(workout.id, workout);
    } else {
      provider.addWorkout(workout);
    }
    
    Navigator.pop(context); // Fermer le loading
    Navigator.pop(context); // Retourner à l'écran précédent
    
    // Afficher un message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(_isEdit ? 'Entraînement modifié avec succès!' : 'Entraînement ajouté avec succès!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // AppBar moderne avec gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  _isEdit ? 'Modifier l\'entraînement' : 'Nouvel entraînement',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          
          // Contenu principal
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card principale
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header de la section
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.fitness_center,
                                      color: theme.primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Détails de l\'entraînement',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      Text(
                                        'Remplissez les informations ci-dessous',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: 32),
                              
                              // Nom de l'entraînement
                              _buildInputField(
                                label: 'Nom de l\'entraînement',
                                hint: 'Ex: Running matinal',
                                icon: Icons.edit_note,
                                initialValue: _name,
                                validator: (v) => v == null || v.isEmpty ? 'Veuillez entrer un nom' : null,
                                onSaved: (v) => _name = v ?? '',
                              ),
                              
                              SizedBox(height: 24),
                              
                              // Type d'entraînement (grille de sélection)
                              Text(
                                'Type d\'entraînement',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              SizedBox(height: 12),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.8,
                                ),
                                itemCount: _workoutTypes.length,
                                itemBuilder: (context, index) {
                                  final type = _workoutTypes.keys.elementAt(index);
                                  final typeData = _workoutTypes[type]!;
                                  final isSelected = _selectedType == type;
                                  
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedType = type),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                          ? typeData['color'].withOpacity(0.15)
                                          : Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected 
                                            ? typeData['color'] 
                                            : Color(0xFFE2E8F0),
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            typeData['icon'],
                                            color: isSelected 
                                              ? typeData['color'] 
                                              : Color(0xFF64748B),
                                            size: 24,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            type,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                              color: isSelected 
                                                ? typeData['color'] 
                                                : Color(0xFF64748B),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              
                              SizedBox(height: 24),
                              
                              // Durée
                              _buildInputField(
                                label: 'Durée (minutes)',
                                hint: 'Ex: 30',
                                icon: Icons.timer,
                                initialValue: _duration == 0 ? '' : _duration.toString(),
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || v.isEmpty ? 'Veuillez entrer une durée' : null,
                                onSaved: (v) => _duration = int.tryParse(v ?? '') ?? 0,
                              ),
                              
                              SizedBox(height: 24),
                              
                              // Sélecteur de date moderne
                              Text(
                                'Date de l\'entraînement',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              SizedBox(height: 12),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _date,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: theme.primaryColor,
                                            onPrimary: Colors.white,
                                            surface: Colors.white,
                                          ),
                                          dialogBackgroundColor: Colors.white,
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) setState(() => _date = picked);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.calendar_today,
                                          color: theme.primaryColor,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Date sélectionnée',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            '${_date.day}/${_date.month}/${_date.year}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.chevron_right,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 32),
                      
                      // Bouton de sauvegarde moderne
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isEdit ? Icons.check_circle : Icons.add_circle,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                _isEdit ? 'Mettre à jour' : 'Ajouter l\'entraînement',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    String? initialValue,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          validator: validator,
          onSaved: onSaved,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.normal,
            ),
            prefixIcon: Container(
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }
}
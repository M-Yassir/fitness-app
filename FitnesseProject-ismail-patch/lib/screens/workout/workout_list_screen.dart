import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../models/workout_model.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _filterType = 'Tous';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
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

  // Fonction pour obtenir l'icône en fonction du type d'entraînement
  IconData _getWorkoutIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cardio':
        return Icons.favorite;
      case 'musculation':
        return Icons.fitness_center;
      case 'hiit':
        return Icons.flash_on;
      case 'yoga':
        return Icons.self_improvement;
      case 'étirements':
        return Icons.accessibility_new;
      case 'course':
        return Icons.directions_run;
      case 'natation':
        return Icons.pool;
      default:
        return Icons.sports;
    }
  }

  // Fonction pour obtenir la couleur en fonction du type d'entraînement
  Color _getWorkoutColor(String type) {
    switch (type.toLowerCase()) {
      case 'cardio':
        return Color(0xFFE74C3C);
      case 'musculation':
        return Color(0xFF3498DB);
      case 'hiit':
        return Color(0xFFF39C12);
      case 'yoga':
        return Color(0xFF1ABC9C);
      case 'étirements':
        return Color(0xFF9B59B6);
      case 'course':
        return Color(0xFF27AE60);
      case 'natation':
        return Color(0xFF17A2B8);
      default:
        return Color(0xFF6C757D);
    }
  }

  List<WorkoutModel> _getFilteredWorkouts(List<WorkoutModel> workouts) {
    if (_filterType == 'Tous') return workouts;
    return workouts.where((workout) => workout.type == _filterType).toList();
  }

  // Fonction pour calculer le nombre d'entraînements cette semaine
  int _calculateWeeklyWorkouts(List<WorkoutModel> workouts) {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
    
    return workouts.where((workout) => 
      workout.date.isAfter(startOfWeek) || 
      workout.date.isAtSameMomentAs(startOfWeek)
    ).length;
  }

  // Widget pour les statistiques
  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Widget pour les filtres
  Widget _buildFilterChip(String type) {
    final isSelected = _filterType == type;
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filterType = type;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Color(0xFFE2E8F0),
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ] : [],
          ),
          child: Text(
            type,
            style: TextStyle(
              color: isSelected ? Colors.white : Color(0xFF64748B),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // Bottom sheet pour les filtres
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtrer par type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Tous',
                'Cardio',
                'Musculation',
                'HIIT',
                'Yoga',
                'Étirements',
                'Course',
                'Natation'
              ].map((type) => _buildFilterChip(type)).toList(),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget pour l'état vide
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.fitness_center_outlined,
              size: 60,
              color: Color(0xFF94A3B8),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Aucun entraînement',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Commencez par ajouter votre\npremier entraînement',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/workout_form'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 20),
                SizedBox(width: 8),
                Text(
                  'Ajouter un entraînement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Confirmation de suppression
  void _showDeleteConfirmation(BuildContext context, WorkoutModel workout) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Supprimer l\'entraînement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer "${workout.name}" ?\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Annuler',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<WorkoutProvider>(context, listen: false)
                .deleteWorkout(workout.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Entraînement supprimé'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allWorkouts = Provider.of<WorkoutProvider>(context).workouts;
    final workouts = _getFilteredWorkouts(allWorkouts);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // AppBar moderne avec gradient
          SliverAppBar(
            expandedHeight: 200,
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
                centerTitle: false,
                titlePadding: EdgeInsets.only(left: 24, bottom: 16),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes Entraînements',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      'Gérez vos séances de sport',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(right: 8, top: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.tune, color: Colors.white),
                  onPressed: () => _showFilterBottomSheet(context),
                ),
              ),
            ],
          ),
          
          // En-tête statistiques
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                margin: EdgeInsets.all(24),
                padding: EdgeInsets.all(24),
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          color: theme.primaryColor,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Statistiques',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          '${allWorkouts.length}',
                          'Entraînements',
                          Icons.fitness_center_rounded,
                          Color(0xFF3B82F6),
                        ),
                        _buildStatItem(
                          context,
                          '${allWorkouts.fold(0, (sum, item) => sum + item.duration)}',
                          'Minutes',
                          Icons.timer_rounded,
                          Color(0xFF10B981),
                        ),
                        _buildStatItem(
                          context,
                          '${_calculateWeeklyWorkouts(allWorkouts)}',
                          'Cette semaine',
                          Icons.calendar_today_rounded,
                          Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Filtres rapides
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtres rapides',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Tous'),
                        ...['Cardio', 'Musculation', 'HIIT', 'Yoga'].map(
                          (type) => _buildFilterChip(type),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(child: SizedBox(height: 24)),
          
          // Titre de la section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Historique des entraînements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (workouts.isNotEmpty)
                    Text(
                      '${workouts.length} séance${workouts.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(child: SizedBox(height: 16)),
          
          // Liste des entraînements
          workouts.isEmpty 
            ? SliverFillRemaining(
                child: _buildEmptyState(context),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final workout = workouts[index];
                    final workoutColor = _getWorkoutColor(workout.type);
                    final workoutIcon = _getWorkoutIcon(workout.type);
                    final formattedDate = DateFormat('dd MMM yyyy', 'fr_FR').format(workout.date);
                    
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 15,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.pushNamed(
                                context, 
                                '/workout_detail', 
                                arguments: workout
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: workoutColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Icon(
                                      workoutIcon,
                                      color: workoutColor,
                                      size: 28,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          workout.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: workoutColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                workout.type,
                                                style: TextStyle(
                                                  color: workoutColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Icon(
                                              Icons.timer_outlined,
                                              size: 16,
                                              color: Color(0xFF64748B),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '${workout.duration} min',
                                              style: TextStyle(
                                                color: Color(0xFF64748B),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          formattedDate,
                                          style: TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert_rounded,
                                      color: Color(0xFF64748B),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        Navigator.pushNamed(
                                          context, 
                                          '/workout_form', 
                                          arguments: workout
                                        );
                                      } else if (value == 'delete') {
                                        _showDeleteConfirmation(context, workout);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_rounded, color: theme.primaryColor, size: 20),
                                            SizedBox(width: 12),
                                            Text('Modifier'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                                            SizedBox(width: 12),
                                            Text('Supprimer'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: workouts.length,
                ),
              ),
          
          // Padding en bas pour le FAB
          SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/workout_form'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: Icon(Icons.add),
        label: Text(
          'Ajouter',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/meals');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
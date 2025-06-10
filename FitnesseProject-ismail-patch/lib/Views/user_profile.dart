import 'package:flutter/material.dart';
import 'package:flutter_sqlite_auth_app/Components/colors.dart';
import 'package:flutter_sqlite_auth_app/JSON/users.dart';
import '../SQLite/database_helper.dart';

class UserProfileScreen extends StatefulWidget {
  final Users? profile;
  
  const UserProfileScreen({Key? key, this.profile}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;
  String _bmiResult = '';
  String _bmiCategory = '';
  Color _bmiColor = Colors.grey;

  late AnimationController _animationController;
  late AnimationController _bmiController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bmiAnimation;

  @override
  void initState() {
    super.initState();
    ageController.text = widget.profile?.age?.toString() ?? '';
    weightController.text = widget.profile?.weight?.toString() ?? '';
    heightController.text = widget.profile?.height?.toString() ?? '';
    
    _initAnimations();
    _calculateBMI();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _bmiController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _bmiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bmiController,
      curve: Curves.bounceOut,
    ));
    
    _animationController.forward();
  }

  void _calculateBMI() {
    if (weightController.text.isNotEmpty && heightController.text.isNotEmpty) {
      final weight = double.tryParse(weightController.text);
      final height = double.tryParse(heightController.text);
      
      if (weight != null && height != null && height > 0) {
        final heightInMeters = height / 100;
        final bmi = weight / (heightInMeters * heightInMeters);
        
        setState(() {
          _bmiResult = bmi.toStringAsFixed(1);
          
          if (bmi < 18.5) {
            _bmiCategory = 'Sous-poids';
            _bmiColor = Colors.blue;
          } else if (bmi < 25) {
            _bmiCategory = 'Poids normal';
            _bmiColor = Colors.green;
          } else if (bmi < 30) {
            _bmiCategory = 'Surpoids';
            _bmiColor = Colors.orange;
          } else {
            _bmiCategory = 'Obésité';
            _bmiColor = Colors.red;
          }
        });
        
        _bmiController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bmiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF5B2C87),
              Color(0xFF2D1B69),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header avec bouton retour et titre
                _buildModernHeader(),
                
                // Contenu principal scrollable
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          
                          // Card de profil avec avatar
                          _buildProfileCard(),
                          
                          const SizedBox(height: 24),
                          
                          // Card BMI
                          if (_bmiResult.isNotEmpty) _buildBMICard(),
                          
                          if (_bmiResult.isNotEmpty) const SizedBox(height: 24),
                          
                          // Card formulaire
                          _buildFormCard(),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const Spacer(),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Color(0xFFE8EAED)],
            ).createShader(bounds),
            child: const Text(
              "PROFILE",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Avatar avec bordure dégradée
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(
                    Icons.person_rounded,
                    size: 60,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Nom avec effet dégradé
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFE8EAED)],
              ).createShader(bounds),
              child: Text(
                widget.profile?.fullName ?? "Utilisateur",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Email
            Text(
              widget.profile?.email ?? "",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICard() {
    return ScaleTransition(
      scale: _bmiAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_bmiColor.withOpacity(0.8), _bmiColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Indice de Masse Corporelle",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _bmiResult,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _bmiColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _bmiColor.withOpacity(0.5)),
                            ),
                            child: Text(
                              _bmiCategory,
                              style: TextStyle(
                                color: _bmiColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre de section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFE8EAED)],
                  ).createShader(bounds),
                  child: const Text(
                    "Informations Physiques",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Champs de formulaire
            _buildModernFormField(
              controller: ageController,
              label: "Âge",
              icon: Icons.calendar_today_rounded,
              suffix: "ans",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre âge';
                }
                if (int.tryParse(value) == null) {
                  return 'Veuillez entrer un nombre valide';
                }
                return null;
              },
              onChanged: (value) => _calculateBMI(),
            ),
            
            const SizedBox(height: 20),
            
            _buildModernFormField(
              controller: weightController,
              label: "Poids",
              icon: Icons.monitor_weight_rounded,
              suffix: "kg",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre poids';
                }
                if (double.tryParse(value) == null) {
                  return 'Veuillez entrer un nombre valide';
                }
                return null;
              },
              onChanged: (value) => _calculateBMI(),
            ),
            
            const SizedBox(height: 20),
            
            _buildModernFormField(
              controller: heightController,
              label: "Taille",
              icon: Icons.height_rounded,
              suffix: "cm",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre taille';
                }
                if (double.tryParse(value) == null) {
                  return 'Veuillez entrer un nombre valide';
                }
                return null;
              },
              onChanged: (value) => _calculateBMI(),
            ),
            
            const SizedBox(height: 32),
            
            // Bouton de sauvegarde
            _buildModernSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String suffix,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        enabled: _isEditing,
        validator: validator,
        onChanged: onChanged,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
          suffixText: suffix,
          suffixStyle: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          errorStyle: TextStyle(
            color: Colors.red.shade300,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildModernSaveButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
            Color(0xFF667eea),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _isLoading ? null : _saveProfile,
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "SAUVEGARDE...",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.save_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "SAUVEGARDER",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(milliseconds: 1500));

      try {
        final updatedUser = Users(
          usrId: widget.profile?.usrId,
          fullName: widget.profile?.fullName,
          email: widget.profile?.email,
          usrName: widget.profile?.usrName ?? "",
          password: widget.profile?.password ?? "",
          age: int.parse(ageController.text),
          weight: double.parse(weightController.text),
          height: double.parse(heightController.text),
        );

        final result = await DatabaseHelper().updateUser(updatedUser);
        
        setState(() {
          _isLoading = false;
          _isEditing = false;
        });
        
        if (!mounted) return;
        
        if (result > 0) {
          _showModernSnackBar(
            "Profil mis à jour avec succès",
            Icons.check_circle_rounded,
            Colors.green,
          );
        } else {
          _showModernSnackBar(
            "Erreur lors de la mise à jour",
            Icons.error_rounded,
            Colors.red,
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showModernSnackBar(
          "Erreur: $e",
          Icons.error_rounded,
          Colors.red,
        );
      }
    }
  }

  void _showModernSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
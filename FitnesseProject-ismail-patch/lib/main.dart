import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sqlite_auth_app/Views/auth.dart';
import 'package:flutter_sqlite_auth_app/providers/meal_provider.dart';
import 'package:flutter_sqlite_auth_app/providers/workout_provider.dart';
import 'package:flutter_sqlite_auth_app/providers/auth_provider.dart';
import 'package:flutter_sqlite_auth_app/providers/meal_api_provider.dart';
import 'package:flutter_sqlite_auth_app/screens/dashboard/dashboard_screen.dart';
import 'package:flutter_sqlite_auth_app/screens/auth/login_screen.dart';
import 'package:flutter_sqlite_auth_app/screens/auth/register_screen.dart';
import 'package:flutter_sqlite_auth_app/screens/workout/workout_list_screen.dart';
import 'package:flutter_sqlite_auth_app/screens/workout/workout_form_screen.dart';
import 'package:flutter_sqlite_auth_app/screens/meal/meal_list_screen.dart';
import 'package:flutter_sqlite_auth_app/screens/meal/meal_form_screen.dart';
import 'package:flutter_sqlite_auth_app/screens/meal/meal_api_screen.dart';
import 'package:flutter_sqlite_auth_app/screens/profile/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_locale.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de la locale pour les dates
  await initializeDateFormatting('fr_FR', null);

  // Configuration de l'interface système
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Lancement de l'application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => MealApiProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fitness Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.blue.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            labelStyle: const TextStyle(color: Colors.blue),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.blueGrey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            // Si l'utilisateur est connecté, aller au dashboard
            if (auth.currentUser != null) {
              return const DashboardScreen();
            } else {
              // Sinon, aller à l'écran d'authentification
              return const AuthScreen();
            }
          },
        ),
        // Définition de toutes les routes
        routes: {
          '/dashboard': (_) => const DashboardScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/workouts': (_) => const WorkoutListScreen(),
          '/workout_form': (_) => const WorkoutFormScreen(),
          '/meals': (_) => const MealListScreen(),
          '/meal_form': (_) => const MealFormScreen(),
          '/meal_api': (_) => const MealApiScreen(),
          '/profile': (_) => const ProfileScreen(),
        },
        // Gestion des routes non trouvées
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const AuthScreen(),
          );
        },
      ),
    );
  }
}
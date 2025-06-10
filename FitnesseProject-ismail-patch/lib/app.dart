import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/meal_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/workout/workout_list_screen.dart';
import 'screens/workout/workout_form_screen.dart';
import 'screens/meal/meal_list_screen.dart';
import 'screens/meal/meal_form_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/gradient_background.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
      ],
      child: MaterialApp(
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
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.currentUser != null) {
              return const DashboardScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
        routes: {
          '/dashboard': (_) => const DashboardScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/workouts': (_) => const WorkoutListScreen(),
          '/workout_form': (_) => const WorkoutFormScreen(),
          '/meals': (_) => const MealListScreen(),
          '/meal_form': (_) => const MealFormScreen(),
          '/profile': (_) => const ProfileScreen(),
        },
      ),
    );
  }
} 
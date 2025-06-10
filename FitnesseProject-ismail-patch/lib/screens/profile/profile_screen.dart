import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: Text('No user info'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue.shade200,
                                child: const Icon(Icons.person, color: Colors.white),
                                radius: 28,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                                  const SizedBox(height: 4),
                                  Text(user.email, style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Provider.of<AuthProvider>(context, listen: false).logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/workouts');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/meals');
          }
        },
      ),
    );
  }
} 
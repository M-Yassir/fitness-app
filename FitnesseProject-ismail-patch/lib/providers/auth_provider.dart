import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    // Mock login
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = UserModel(id: '1', email: email, name: 'Test User');
    notifyListeners();
    return true;
  }

  Future<bool> register(String email, String password, String name) async {
    // Mock register
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = UserModel(id: '1', email: email, name: name);
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
} 
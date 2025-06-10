import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../JSON/users.dart';



class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  final String databaseName = "auth.db";

  final String userTable = '''
    CREATE TABLE users (
      usrId INTEGER PRIMARY KEY AUTOINCREMENT,
      fullName TEXT,
      email TEXT,
      usrName TEXT UNIQUE,
      usrPassword TEXT,
      age INTEGER,
      weight REAL,
      height REAL
    )
  ''';
 

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, databaseName);

    
    return openDatabase(
      path, 
      version: 1, 
      onCreate: (db, version) async {
        await db.execute(userTable);
        
      }
    );
  }
  //  AJOUTE cette méthode ici
  Future<bool> isUsernameTaken(String username) async {
    final dbClient = await database;
    var res = await dbClient.query(
      'users',
      where: 'usrName = ?',
      whereArgs: [username],
    );
    return res.isNotEmpty;
  }

  // Authentification sécurisée
  Future<bool> authenticate(Users usr) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'usrName = ? AND usrPassword = ?',
      whereArgs: [usr.usrName, usr.password],
    );
    return result.isNotEmpty;
  }

  // Inscription
  Future<int> createUser(Users usr) async {
  final db = await database;
  
  // Check if user already exists
  final existing = await db.query(
    'users',
    where: 'usrName = ?',
    whereArgs: [usr.usrName],
  );
  
  if (existing.isNotEmpty) {
    throw Exception('Username "${usr.usrName}" is already taken');
  }
  
  return await db.insert('users', usr.toMap());
}

  // Récupération d'un utilisateur
  Future<Users?> getUser(String usrName) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'usrName = ?',
      whereArgs: [usrName],
    );
    return result.isNotEmpty ? Users.fromMap(result.first) : null;
  }

  // Mise à jour d'un utilisateur
  Future<int> updateUser(Users user) async {
    final Database db = await database;
    return await db.update(
      'users',
      {
        'fullName': user.fullName,
        'email': user.email,
        'usrName': user.usrName,
        'usrPassword': user.password,
        'age': user.age,
        'weight': user.weight,
        'height': user.height,
      },
      where: 'usrId = ?',
      whereArgs: [user.usrId],
    );
  }

  // Suppression d'un utilisateur
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'usrId = ?',
      whereArgs: [id],
    );
  }

  // Récupération de tous les utilisateurs
  Future<List<Users>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => Users.fromMap(maps[i]));
  }
}
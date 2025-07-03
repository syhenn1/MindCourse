import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:mindcourse/models/user.dart';
import 'package:mindcourse/models/subject.dart';
import 'package:mindcourse/models/course.dart';

class DbHelper {
  static final DbHelper _dbHelper = DbHelper._createObject();
  static Database? _database;

  DbHelper._createObject();

  factory DbHelper() {
    return _dbHelper;
  }

  Future<Database> initDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/mindcourse.db';

    var db = await openDatabase(path, version: 1, onCreate: _createDb);
    return db;
  }

  void _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        email TEXT,
        password TEXT,
        date_added DATE,
        is_deleted INTEGER,
        semester INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE subjects (
        subject_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        date_added DATE,
        is_deleted INTEGER,
        user_id INTEGER,
        semester INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(user_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE courses (
        course_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        deadline DATE,
        status TEXT,
        date_added DATE,
        is_deleted INTEGER,
        user_id INTEGER,
        subject_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
      )
    ''');
  }

  Future<Database> get database async {
    _database ??= await initDb();
    return _database!;
  }

  // ========== CRUD USERS ==========

  Future<int> createUser(User user, {required String name}) async {
    Database db = await this.database;
    return await db.insert('users', user.toMap());
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<List<Map<String, dynamic>>> getUsersMapList() async {
    final db = await database;
    return await db.query('users', orderBy: 'name');
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'user_id = ?',
      whereArgs: [user.userId],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'user_id = ?', whereArgs: [id]);
  }

  Future<List<User>> getUserList() async {
    final mapList = await getUsersMapList();
    return mapList.map((map) => User.fromMap(map)).toList();
  }

  // ========== CRUD SUBJECTS ==========
  Future<int> insertSubject(Subject subject) async {
    final db = await database;
    return await db.insert('subjects', subject.toMap());
  }

  Future<List<Map<String, dynamic>>> getSubjectsMapList() async {
    final db = await database;
    return await db.query('subjects', orderBy: 'name');
  }

  Future<int> updateSubject(Subject subject) async {
    final db = await database;
    return await db.update(
      'subjects',
      subject.toMap(),
      where: 'subject_id = ?',
      whereArgs: [subject.subjectId],
    );
  }

  Future<int> deleteSubject(int id) async {
    final db = await database;
    return await db.delete(
      'subjects',
      where: 'subject_id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Subject>> getSubjectList() async {
    final mapList = await getSubjectsMapList();
    return mapList.map((map) => Subject.fromMap(map)).toList();
  }

  // ========== CRUD COURSES ==========
  Future<int> insertCourse(Course course) async {
    final db = await database;
    return await db.insert('courses', course.toMap());
  }

  Future<List<Map<String, dynamic>>> getCoursesMapList() async {
    final db = await database;
    return await db.query('courses', orderBy: 'deadline');
  }

  Future<int> updateCourse(Course course) async {
    final db = await database;
    return await db.update(
      'courses',
      course.toMap(),
      where: 'course_id = ?',
      whereArgs: [course.courseId],
    );
  }

  Future<int> deleteCourse(int id) async {
    final db = await database;
    return await db.delete('courses', where: 'course_id = ?', whereArgs: [id]);
  }

  Future<List<Course>> getCourseList() async {
    final mapList = await getCoursesMapList();
    return mapList.map((map) => Course.fromMap(map)).toList();
  }

  Future<User?> getUserByEmail(String email) async {
    Database db = await this.database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'user_id = ?', // Mencari berdasarkan kolom primary key
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      // Jika data ditemukan, konversi map menjadi objek User.
      return User.fromMap(maps.first);
    }
    // Mengembalikan null jika tidak ada pengguna dengan ID tersebut.
    return null;
  }
}

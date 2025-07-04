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
        semester INTEGER,
        semester_end DATE,
        notification_sound TEXT,
        UNIQUE(email),
        UNIQUE(phone),
        UNIQUE(name)
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
        deadline_day DATE,
        deadline_time TEXT,
        status TEXT,
        date_added DATE,
        is_deleted INTEGER,
        is_done INTEGER,
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

  Future<User?> getUserByName(String name) async {
    Database db = await this.database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'name = ?',
      whereArgs: [name],
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

  Future<List<Map<String, dynamic>>> getCoursesByUserId(int userId) async {
    final db = await database;
    return await db.query(
      'courses',
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [userId],
      orderBy: 'deadline_day ASC, deadline_time ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getSubjectsByUserId(int userId) async {
    final db = await database;
    return await db.query(
      'subjects',
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [userId],
      orderBy: 'semester ASC, name ASC',
    );
  }

  Future<int> updateUserInfo(int userId, String phone, int semester) async {
    final db = await database;
    return await db.update(
      'users',
      {'phone': phone, 'semester': semester},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Update semester seluruh user jika semester_end telah lewat (misalnya berdasarkan hari ini)
  Future<void> autoUpdateSemester() async {
    final db = await database;
    final today = DateTime.now();

    final users = await db.query('users', where: 'is_deleted = 0');

    for (final user in users) {
      final userId = user['user_id'] as int;
      int? currentSemester = (user['semester'] ?? 1) as int?;
      String? semesterEndStr = user['semester_end'] as String?;

      if (semesterEndStr == null) continue;

      DateTime semesterEnd;
      try {
        semesterEnd = DateTime.parse(semesterEndStr);
      } catch (e) {
        continue; // skip kalau parsing gagal
      }

      if (today.isBefore(semesterEnd)) {
        continue; // belum waktunya naik semester
      }

      // Hitung berapa semester telah berlalu (per 6 bulan = 180 hari)
      int semesterPassed =
          ((today.difference(semesterEnd).inDays) / 180).floor() + 1;

      final newSemester = currentSemester! + semesterPassed;
      final newSemesterEnd = semesterEnd.add(
        Duration(days: 180 * semesterPassed),
      );

      await db.update(
        'users',
        {
          'semester': newSemester,
          'semester_end': newSemesterEnd.toIso8601String().substring(0, 10),
        },
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }
  }

  Future<int> updateUserSemester(int userId) async {
    final db = await database;
    return await db.update(
      'users',
      {'semester': 1},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}

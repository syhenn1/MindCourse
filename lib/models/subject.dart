import 'package:shared_preferences/shared_preferences.dart';

class Subject {
  int? _subjectId;
  late String _name;
  late String _description;
  late String _dateAdded;
  late int _isDeleted;
  late int _userId;
  late int _semester;

  Subject(
    this._name,
    this._description,
    this._dateAdded,
    this._isDeleted,
    this._userId,
    this._semester,
  );

  static Future<Subject> createEmpty() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId == null) {
      throw Exception(
        "User ID not found in SharedPreferences. User must login.",
      );
    }

    return Subject(
      '',
      '',
      DateTime.now().toIso8601String(),
      0,
      userId,
      1, // default semester
    );
  }

  Subject.fromMap(Map<String, dynamic> map) {
    _subjectId = map['subject_id'];
    _name = map['name'];
    _description = map['description'];
    _dateAdded = map['date_added'];
    _isDeleted = map['is_deleted'];
    _userId = map['user_id'];
    _semester = map['semester'];
  }

  int? get subjectId => _subjectId;
  String get name => _name;
  String get description => _description;
  String get dateAdded => _dateAdded;
  int get isDeleted => _isDeleted;
  int get userId => _userId;
  int get semester => _semester;

  set name(String value) => _name = value;
  set description(String value) => _description = value;
  set dateAdded(String value) => _dateAdded = value;
  set isDeleted(int value) => _isDeleted = value;
  set userId(int value) => _userId = value;
  set semester(int value) => _semester = value;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': _name,
      'description': _description,
      'date_added': _dateAdded,
      'is_deleted': _isDeleted,
      'user_id': _userId,
      'semester': _semester,
    };
    if (_subjectId != null) {
      map['subject_id'] = _subjectId;
    }
    return map;
  }

  @override
  String toString() {
    return 'Subject{subjectId: $_subjectId, name: $_name, userId: $_userId, semester: $_semester}';
  }
}

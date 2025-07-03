class Course {
  int? _courseId;
  late String _name;
  late String _description;
  late String _deadline;
  late String _status;
  late String _dateAdded;
  late int _isDeleted;
  late int _userId;
  late int _subjectId;

  Course(
    this._name,
    this._description,
    this._deadline,
    this._status,
    this._dateAdded,
    this._isDeleted,
    this._userId,
    this._subjectId,
  );

  Course.fromMap(Map<String, dynamic> map) {
    _courseId = map['course_id'];
    _name = map['name'];
    _description = map['description'];
    _deadline = map['deadline'];
    _status = map['status'];
    _dateAdded = map['date_added'];
    _isDeleted = map['is_deleted'];
    _userId = map['user_id'];
    _subjectId = map['subject_id'];
  }

  int? get courseId => _courseId;
  String get name => _name;
  String get description => _description;
  String get deadline => _deadline;
  String get status => _status;
  String get dateAdded => _dateAdded;
  int get isDeleted => _isDeleted;
  int get userId => _userId;
  int get subjectId => _subjectId;

  set name(String value) => _name = value;
  set description(String value) => _description = value;
  set deadline(String value) => _deadline = value;
  set status(String value) => _status = value;
  set dateAdded(String value) => _dateAdded = value;
  set isDeleted(int value) => _isDeleted = value;
  set userId(int value) => _userId = value;
  set subjectId(int value) => _subjectId = value;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': _name,
      'description': _description,
      'deadline': _deadline,
      'status': _status,
      'date_added': _dateAdded,
      'is_deleted': _isDeleted,
      'user_id': _userId,
      'subject_id': _subjectId,
    };
    if (_courseId != null) {
      map['course_id'] = _courseId;
    }
    return map;
  }

  @override
  String toString() {
    return 'Course{courseId: $_courseId, name: $_name, subjectId: $_subjectId, userId: $_userId, status: $_status}';
  }
}

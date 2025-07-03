/// Model data untuk entitas Pengguna (User).
/// Berisi properti dan metode untuk mengelola data pengguna.
class User {
  int? _userId;
  late String _name;
  late String _phone;
  late String _email;
  late String _password;
  late String _dateAdded;
  late int _isDeleted;
  late int _semester;

  // Konstruktor utama (jarang digunakan secara langsung).
  User(
    this._name,
    this._phone,
    this._email,
    this._password,
    this._dateAdded,
    this._isDeleted,
    this._semester,
  );

  // Named constructor untuk membuat instance User baru dengan lebih rapi.
  User.create({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String dateAdded,
    required int isDeleted,
    required int semester,
  }) {
    _name = name;
    _phone = phone;
    _email = email;
    _password = password;
    _dateAdded = dateAdded;
    _isDeleted = isDeleted;
    _semester = semester;
  }

  // Konstruktor untuk membuat instance User dari sebuah Map (misalnya, dari database).
  User.fromMap(Map<String, dynamic> map) {
    _userId = map['user_id'];
    _name = map['name'];
    _phone = map['phone'];
    _email = map['email'];
    _password = map['password'];
    _dateAdded = map['date_added'];
    _isDeleted = map['is_deleted'];
    _semester = map['semester'];
  }

  // Getter untuk mengakses properti privat.
  int? get userId => _userId;
  String get name => _name;
  String get phone => _phone;
  String get email => _email;
  String get password => _password;
  String get dateAdded => _dateAdded;
  int get isDeleted => _isDeleted;
  int get semester => _semester;

  // Setter untuk mengubah nilai properti privat.
  set name(String value) => _name = value;
  set phone(String value) => _phone = value;
  set email(String value) => _email = value;
  set password(String value) => _password = value;
  set dateAdded(String value) => _dateAdded = value;
  set isDeleted(int value) => _isDeleted = value;
  set semester(int value) => _semester = value;

  // Metode untuk mengonversi instance User menjadi Map (untuk disimpan ke database).
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': _name,
      'phone': _phone,
      'email': _email,
      'password': _password,
      'date_added': _dateAdded,
      'is_deleted': _isDeleted,
      'semester': _semester,
    };
    if (_userId != null) {
      map['user_id'] = _userId;
    }
    return map;
  }

  @override

  String toString() {
    return 'User{userId: $_userId, name: $_name, phone: $_phone, email: $_email, semester: $_semester}';
  }
}

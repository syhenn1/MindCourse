class Course {
  String? courseId;
  late String name;
  late String description;
  late String deadlineDay; // format: yyyy-MM-dd
  late String deadlineTime; // format: HH:mm:ss
  late String status;
  late String dateAdded;
  late int isDeleted;
  late int isDone;
  late String doneDate;
  late String userId;
  late String subjectId;

  Course(
    this.courseId,
    this.name,
    this.description,
    this.deadlineDay,
    this.deadlineTime,
    this.status,
    this.dateAdded,
    this.isDeleted,
    this.isDone,
    this.doneDate,
    this.userId,
    this.subjectId,
  );

  Course.fromMap(Map<String, dynamic> map) {
    courseId = map['course_id'];
    name = map['name'];
    description = map['description'];
    deadlineDay = map['deadline_day'];
    deadlineTime = map['deadline_time'];
    status = map['status'];
    dateAdded = map['date_added'];
    isDeleted = map['is_deleted'];
    isDone = map['is_done'];
    doneDate = map['done_date'];
    userId = map['user_id'];
    subjectId = map['subject_id'];
  }

  Map<String, dynamic> toMap() {
    return {
      'course_id': courseId,
      'name': name,
      'description': description,
      'deadline_day': deadlineDay,
      'deadline_time': deadlineTime,
      'status': status,
      'date_added': dateAdded,
      'is_deleted': isDeleted,
      'is_done': isDone,
      'done_date': doneDate,
      'user_id': userId,
      'subject_id': subjectId,
    };
  }

  @override
  String toString() {
    return 'Course{courseId: $courseId, name: $name, deadline: $deadlineDay $deadlineTime, status: $status, dateAdded: $dateAdded, isDeleted: $isDeleted, isDone: $isDone, doneDate: $doneDate, userId: $userId, subjectId: $subjectId}';
  }
}

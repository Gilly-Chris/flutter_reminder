
class Reminder {
  int id, userId;
  String title, note, time;
  String regDate, status;
  String? repeatType, readAt;

  Reminder({
    required this.id,
    required this.userId,
    required this.title,
    required this.note,
    required this.time,
    required this.repeatType,
    required this.regDate,
    required this.status,
    required this.readAt
  });

  factory Reminder.fromJson(Map<String, dynamic> dataMap) => Reminder(
    id: dataMap["id"] as int,
    userId: dataMap["user_id"] as int,
    title: dataMap["title"] as String,
    note: dataMap["note"] as String,
    time: dataMap["time"] as String,
    repeatType: dataMap["repeat_type"] as String?,
    regDate: dataMap["reg_date"] as String,
    status: dataMap["status"] as String,
    readAt: dataMap["read_at"] as String?
  );

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "title": title,
      "note": note,
      "time": time,
      "repeat_type": repeatType,
      "reg_date": regDate,
      "status": status,
      "read_at": readAt
    };
  }

  @override
  String toString() {
    return 'Reminder(id: $id, user_id: $userId, title: $title, note: $note, time: $time, repeat_type: $repeatType, reg_date: $regDate'
        'status: $status, read_at: $readAt})';
  }
}
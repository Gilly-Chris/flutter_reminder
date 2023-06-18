
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/Reminder.dart';

class DatabaseManager {

  Future<List<String>> getReminders() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> reminders = pref.getStringList("reminders") ?? [];
    return reminders;
  }

  Future<void> saveReminders(List<String> reminders) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setStringList("reminders", reminders);
  }

  Future<void> saveReminder(String reminder) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> reminders = await DatabaseManager().getReminders();
    reminders.insert(0, reminder);
    pref.setStringList("reminders", reminders);
  }

  Future<Reminder?> getReminder(int id) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> reminders = pref.getStringList("reminders") ?? [];
    if (reminders.isEmpty) { return null; }
    for(var i = 0; i < reminders.length; i++) {
      Reminder tempReminder = Reminder.fromJson(jsonDecode(reminders[i]) as Map<String, dynamic>);
      if (tempReminder.id == id) {
        reminders.removeAt(i);
        await saveReminders(reminders);
        return tempReminder;
      }
    }
    return null;
  }

  Future<void> clearReminders() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setStringList("reminders", []);
  }

  Future<int> getIdentifier() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getInt("max_id") ?? 0;
  }

  Future<void> setIdentifier(int maxId) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("max_id", maxId);
  }
}

import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reminder/DatabaseManager.dart';

import 'models/Reminder.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  DatabaseManager manager = DatabaseManager();
  List<Reminder> reminders = [];
  List<String> repeatTypes = ["30 minutes", "hourly", "daily", "2 days"];
  String title = "";
  TextEditingController titleController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    getReminders();
    handleAlarmDispatched();
  }

  handleAlarmDispatched() async {
    Alarm.ringStream.stream.listen((data) async {
      await updateReminderStatus(data.id);
      getReminders();
    });
  }

  Future<void> updateReminderStatus(int id) async {
    Reminder? reminder = await DatabaseManager().getReminder(id);
    if (reminder == null) { return; }
    reminder.status = DateTime.now().toLocal().toString();
    await DatabaseManager().saveReminder(jsonEncode(reminder));
  }

  getReminders() async {
    List<String> savedReminders = await manager.getReminders();
    if(savedReminders.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          reminders = savedReminders.map((value) {
            var jsonData = jsonDecode(value) as Map<String, dynamic>;
            return Reminder.fromJson(jsonData);
          }).toList();
        });
      });
    }
  }

  saveReminder(String title) async {
    if (title.isEmpty) {
      return;
    }

    try {
      int currentId = await DatabaseManager().getIdentifier();
      DateTime time = DateTime.now().add(const Duration(seconds: 15)).toLocal();
      Reminder reminder = Reminder(
          id: ++currentId,
          userId: 2, title: title,
          note: "This is a basic 2 minute reminder",
          time: time.toString(),
          repeatType: repeatTypes[Random().nextInt(repeatTypes.length)],
          regDate: DateTime.now().toLocal().toString(),
          status: "unread",
          readAt: null
      );
      await DatabaseManager().saveReminder(jsonEncode(reminder));
      await DatabaseManager().setIdentifier(++currentId);
      getReminders();

      final alarmSettings = AlarmSettings(
        id: reminder.id,
        dateTime: time,
        assetAudioPath: 'assets/sounds/alarm_sound.mp3',
        loopAudio: false,
        vibrate: true,
        fadeDuration: 3.0,
        notificationTitle: reminder.title,
        notificationBody: reminder.note,
        enableNotificationOnKill: true,
      );
      await Alarm.set(alarmSettings: alarmSettings);
      titleController.clear();
      print(reminder.toString());
    } catch(e) {
      if (kDebugMode) {
        print(e);
      }}
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        // leading: const InkWell(
        //   child: Icon(Icons.arrow_back, color: Colors.white,),
        // ),
        title: Text("Reminders", style: theme.textTheme.headline6?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => showAddModal(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          children: [
            Expanded(
                child: ListView.builder(
                    itemCount: reminders.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) => reminderItem(reminders[index])
                )
            )
          ],
        ),
      ),
    );
  }

  Widget reminderItem(Reminder reminder) {
    ThemeData theme = Theme.of(context);

    return  Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 5))
          ]
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(reminder.title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),),
                Text(reminder.note, style: theme.textTheme.bodyMedium,)
              ],
            ),
          ),
          Text(reminder.status == "unread" ? reminder.status.toUpperCase() : "READ", style: const TextStyle(fontSize: 12),)
        ],
      ),
    );
  }

  showAddModal(context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false, // should dialog be dismissed when tapped outside// label for barrier
      transitionDuration: const Duration(milliseconds: 500), // how long it takes to popup dialog after button click
      pageBuilder: (_, __, ___) {
        return StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                appBar: AppBar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    centerTitle: true,
                    leading: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                        }
                    ),
                    title: const Text(
                      "Add Reminder",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    elevation: 0.0
                ),
                backgroundColor: Colors.white,
                body: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: const BoxDecoration(
                      color: Colors.white
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          onChanged: (value) {
                            title = value;
                          },
                          controller: titleController,
                          decoration: const InputDecoration(
                              hintText: "Title",
                              border: UnderlineInputBorder()
                          ),
                        ),

                        const SizedBox(height: 20,),
                        ElevatedButton(
                            onPressed: () {
                              saveReminder(title);
                              Navigator.pop(context);
                            },
                            child: const Text("Save Reminder"))
                      ],
                    ),
                  ),
                ),
              );
            }
        );// your widget implementation
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/add_new_task.dart';
import 'package:frontend/login_page.dart';
import 'package:frontend/settings_page.dart';
import 'package:frontend/utils.dart';
import 'package:frontend/widgets/date_selector.dart';
import 'package:frontend/widgets/task_card.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? selectedDate; // Выбранная дата

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Навигация в зависимости от выбранного индекса
    switch (index) {
      case 0:
        // Переход на главную страницу
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
        break;
      case 1:
        // Переход на страницу настроек
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MySettingsPage()),
        );
        break;
      case 2:
        // Выход из аккаунта
        _logout();
        break;
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit'),
          content: const Text('Are you sure you want to go out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Log out'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddNewTask(),
                ),
              );
            },
            icon: const Icon(
              CupertinoIcons.add,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            DateSelector(
              onDateSelected: (date) {
                setState(() {
                  selectedDate = date; // Обновляем выбранную дату
                });
              },
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("tasks")
                  .where("creator",
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData) {
                  return const Text('No data here');
                }

                // Фильтруем задачи по выбранной дате
                final tasks = selectedDate == null
                    ? snapshot.data!.docs
                    : snapshot.data!.docs.where((task) {
                        final taskDate = task['date'].toDate();
                        return taskDate.year == selectedDate!.year &&
                            taskDate.month == selectedDate!.month &&
                            taskDate.day == selectedDate!.day;
                      }).toList();

                return Expanded(
                  child: ListView.builder(
                    // itemCount: snapshot.data!.docs.length,
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final date = task['date'].toDate();

                      final formattedDateTime =
                          DateFormat('yyyy-MM-dd').format(date);
                      final formattedTime = DateFormat('hh:mm a').format(date);

                      return Dismissible(
                        key: Key(task.id),
                        onDismissed: (direction) async {
                          if (direction == DismissDirection.startToEnd ||
                              direction == DismissDirection.endToStart) {
                            await FirebaseFirestore.instance
                                .collection("tasks")
                                .doc(task.id)
                                .delete();
                          }
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: TaskCard(
                                color: hexToColor(task['color']),
                                // color: hexToColor(
                                //     snapshot.data!.docs[index].data()['color']),
                                headerText: task['title'],
                                descriptionText: task['description'],
                                scheduledDate: formattedDateTime,
                              ),
                            ),
                            Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(
                                color: strengthenColor(
                                  const Color.fromRGBO(246, 222, 194, 1),
                                  0.69,
                                ),
                                image: snapshot.data!.docs[index]
                                            .data()['imageURL'] ==
                                        null
                                    ? null
                                    : DecorationImage(
                                        image: NetworkImage(snapshot
                                            .data!.docs[index]
                                            .data()['imageURL'])),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                formattedTime,
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app),
            label: 'Log out',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

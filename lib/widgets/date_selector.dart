import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatefulWidget {
  final Function(DateTime?) onDateSelected; // Callback для выбранной даты

  const DateSelector({super.key, required this.onDateSelected});

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  DateTime? selectedDate = DateTime.now();
  int weekOffset = 0;
  final int _datesPerPage = 10; // Количество дат для подгрузки
  final List<DateTime> _allDates = []; // Список всех дат
  bool _showAllTasks = false; // Состояние кнопки "All Tasks"

  @override
  void initState() {
    super.initState();
    _loadMoreDates(); // Загружаем первые даты при инициализации
  }

  // Генерация списка дат для текущей недели с учетом смещения
  List<DateTime> generateWeekDates(int weekOffset) {
    final today = DateTime.now();
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    startOfWeek = startOfWeek.add(Duration(days: weekOffset * 5));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  // Генерация списка дат
  List<DateTime> generateDates(int startOffset, int count) {
    final today = DateTime.now();
    DateTime startDate = today.subtract(Duration(days: today.weekday - 1));
    startDate = startDate.add(Duration(days: startOffset * 7));
    return List.generate(
        count, (index) => startDate.add(Duration(days: index)));
  }

  // Подгрузка новых дат
  void _loadMoreDates() {
    final newDates = generateDates(weekOffset, _datesPerPage);
    setState(() {
      _allDates.addAll(newDates);
      weekOffset++; // Увеличиваем смещение для следующей подгрузки
    });
  }

  // // Проверка, чтобы неделя не уходила в прошлое
  // bool get canGoToPreviousWeek {
  //   final firstDayOfCurrentWeek =
  //       DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  //   final firstDayOfDisplayedWeek =
  //       firstDayOfCurrentWeek.add(Duration(days: weekOffset * 7));
  //   return firstDayOfDisplayedWeek.isAfter(firstDayOfCurrentWeek);
  // }

  // Обработчик нажатия на кнопку "All Tasks"
  void _toggleAllTasks() {
    setState(() {
      _showAllTasks = !_showAllTasks;
      if (_showAllTasks) {
        selectedDate = null; // Сбрасываем выбранную дату
        widget.onDateSelected(null); // Уведомляем родительский виджет
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> weekDates = generateWeekDates(weekOffset);
    String monthName = DateFormat('MMMM').format(weekDates.first);

    return Column(
      children: [
        // Панель с кнопками переключения недель и названием месяца
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(
            bottom: 10.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  setState(() {
                    weekOffset--;
                  });
                }, // Блокируем кнопку, если неделя в прошлом
              ),
              Text(
                monthName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  setState(() {
                    weekOffset++;
                  });
                },
              ),
            ],
          ),
        ),

        // Список дней недели
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weekDates.length,
              itemBuilder: (context, index) {
                DateTime date = weekDates[index];
                bool isSelected = !_showAllTasks &&
                    DateFormat('d').format(selectedDate ?? DateTime.now()) ==
                        DateFormat('d').format(date) &&
                    (selectedDate?.month == date.month) &&
                    (selectedDate?.year == date.year);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                      _showAllTasks =
                          false; // Отключаем "All Tasks" при выборе даты
                    });
                    widget.onDateSelected(date); // Вызываем callback
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 70,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.deepOrangeAccent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.deepOrangeAccent
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('d').format(date), // День месяца
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          DateFormat('E')
                              .format(date), // День недели (Mon, Tue)
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton(
            onPressed: _toggleAllTasks,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _showAllTasks ? Colors.deepOrangeAccent : Colors.grey[300],
              foregroundColor: _showAllTasks ? Colors.white : Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('All Tasks'),
          ),
        ),
      ],
    );
  }
}

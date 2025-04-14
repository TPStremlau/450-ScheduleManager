import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'day_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Fetches a map of holiday dates to holiday names for the selected month
Future<Map<DateTime, String>> getHolidaysForMonth(DateTime selectedDate) async {
  Map<DateTime, String> holidays = {};

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('publicHolidays')
      .get();

  for (var doc in snapshot.docs) {
    DateTime holidayDate = (doc['date'] as Timestamp).toDate().toLocal();
    holidayDate = DateTime(holidayDate.year, holidayDate.month, holidayDate.day); // Strip time
    String name = doc['name'];
    holidays[holidayDate] = name;
  }

  return holidays;
}

/// Builds a calendar month view showing holidays
Widget buildMonthView(DateTime selectedDate) {
  int daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
  int firstDayOfWeek = DateTime(selectedDate.year, selectedDate.month, 1).weekday;

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          DateFormat.yMMMM().format(selectedDate),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Text('S', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('M', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('T', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('W', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('T', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('F', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('S', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      FutureBuilder<Map<DateTime, String>>(
        future: getHolidaysForMonth(selectedDate),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            );
          }

          Map<DateTime, String> holidays = snapshot.data!;

          return Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.2,
              ),
              itemCount: daysInMonth + firstDayOfWeek - 1,
              itemBuilder: (context, index) {
                if (index < firstDayOfWeek - 1) {
                  return Container();
                }

                int day = index - firstDayOfWeek + 2;
                if (day > daysInMonth) {
                  return Container();
                }

                DateTime currentDay = DateTime(selectedDate.year, selectedDate.month, day);
                currentDay = DateTime(currentDay.year, currentDay.month, currentDay.day); // Strip time

                bool isHoliday = holidays.containsKey(currentDay);
                String? holidayName = holidays[currentDay];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DayView(date: currentDay,)
                          ,
                      ),
                    );
                  },
                  child: Card(
                    color: isHoliday ? Colors.pink.shade100 : Colors.blue.shade100,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$day",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          if (isHoliday)
                            Text(
                              holidayName ?? 'Holiday',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    ],
  );
}

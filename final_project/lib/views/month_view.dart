import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'day_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Fetches a map of holiday dates to holiday names for the selected month.
Future<Map<DateTime, String>> getHolidaysForMonth(DateTime selectedDate) async {
  Map<DateTime, String> holidays = {};

  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('publicHolidays').get();

  for (var doc in snapshot.docs) {
    // Convert the stored timestamp to a local DateTime and strip off the time.
    DateTime holidayDate = (doc['date'] as Timestamp).toDate().toLocal();
    holidayDate = DateTime(holidayDate.year, holidayDate.month, holidayDate.day);
    String name = doc['name'];
    holidays[holidayDate] = name;
  }

  return holidays;
}

/// Builds a calendar month view showing holidays.
Widget buildMonthView(DateTime selectedDate) {
  // Determine total days in the month.
  int daysInMonth =
      DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

  // Adjust blank cell count so that the week begins on Sunday.
  // Dart's DateTime.weekday returns 1 for Monday ... 7 for Sunday.
  // We want to map Sunday (7) to index 0 in our calendar grid.
  int blankCells = DateTime(selectedDate.year, selectedDate.month, 1).weekday % 7;

  // --- Debugging prints ---
  DateTime april15 = DateTime(2025, 4, 15);
  // This should print "Tuesday" if things are right.
  print("DEBUG: April 15, 2025 is: ${DateFormat.EEEE().format(april15)}");
  // Log the calculated blank cells for the start of the month.
  print("DEBUG: Blank cells for ${DateFormat.yMMMM().format(selectedDate)}: $blankCells");
  // --------------------------

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          DateFormat.yMMMM().format(selectedDate),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      // Weekday headers, starting with Sunday.
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
              // Total grid cells: blank cells + days in month.
              itemCount: daysInMonth + blankCells,
              itemBuilder: (context, index) {
                // For indices in the blank area, return an empty container.
                if (index < blankCells) {
                  return Container();
                }

                // Calculate the day number.
                int day = index - blankCells + 1;
                if (day > daysInMonth) {
                  return Container();
                }

                // Create a DateTime representing the current day (no time portion).
                DateTime currentDay = DateTime(selectedDate.year, selectedDate.month, day);

                // Debug print for each day's computed weekday.
                // For example, for the 15th day, check that it is Tuesday.
                if (day == 15) {
                  print("DEBUG: Computed day ${currentDay.day} is: ${DateFormat.EEEE().format(currentDay)}");
                }

                bool isHoliday = holidays.containsKey(currentDay);
                String? holidayName = holidays[currentDay];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DayView(date: currentDay),
                      ),
                    );
                  },
                  child: Card(
                    color: isHoliday
                        ? Colors.pink.shade100
                        : Colors.blue.shade100,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$day",
                            style: const TextStyle(fontSize: 16),
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

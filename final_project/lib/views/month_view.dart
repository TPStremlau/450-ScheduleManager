// month_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'day_view.dart'; // Import the DayView page

Widget buildMonthView(DateTime selectedDate) {
  int daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
  int firstDayOfWeek = DateTime(selectedDate.year, selectedDate.month, 1).weekday;

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          DateFormat.yMMMM().format(selectedDate), // Shows "March 2025" based on the selected date
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      // Weekday header row
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
      Expanded(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, // 7 days in a week
            childAspectRatio: 1.2,
          ),
          itemCount: daysInMonth + firstDayOfWeek - 1, // Adjust for month start
          itemBuilder: (context, index) {
            if (index < firstDayOfWeek - 1) {
              return Container(); // Empty cells before the month starts
            }
            int day = index - firstDayOfWeek + 2;
            if (day > daysInMonth) {
              return Container(); // Ensure days do not go beyond the month
            }
            return GestureDetector(
              onTap: () {
                // Navigate to the selected day view
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DayView(
                      date: DateTime(selectedDate.year, selectedDate.month, day),
                    ),
                  ),
                );
              },
              child: Card(
                color: Colors.blue.shade100,
                child: Center(
                  child: Text(
                    "$day",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

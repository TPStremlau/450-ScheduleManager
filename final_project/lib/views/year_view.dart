import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'month_view.dart';

// Stateful widget for Year View
class YearViewPage extends StatefulWidget {
  const YearViewPage({super.key});

  @override
  YearViewPageState createState() => YearViewPageState();
}

class YearViewPageState extends State<YearViewPage> {
  DateTime currentDate = DateTime.now(); // Track current year

  // Function to update the year
  void _moveYear(int increment) {
    if (!mounted) return;
    setState(() {
      currentDate = DateTime(currentDate.year + increment, currentDate.month, currentDate.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.y().format(currentDate)), // Show the current year
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _moveYear(-1); // Move to the previous year
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              _moveYear(1); // Move to the next year
            },
          ),
        ],
      ),
      body: buildYearView(),
    );
  }

  // Year View Grid Layout
  Widget buildYearView() {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 columns for 12 months
        childAspectRatio: 1.1, // Adjust for readability
      ),
      itemCount: 12, // 12 months
      itemBuilder: (context, index) {
        DateTime monthDate = DateTime(currentDate.year, index + 1, 1); // Set month for the current year
        return GestureDetector(
          onTap: () {
            // Navigate to the MonthViewPage with the selected month
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MonthViewPage(
                  date: monthDate, // Pass the selected month and year
                ),
              ),
            );
          },
          child: Card(
            color: Colors.blue.shade100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat.MMMM().format(monthDate), // "January", "February"...
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MonthViewPage extends StatelessWidget {
  final DateTime date;

  const MonthViewPage({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    // Use the passed-in date for rendering the month view
    return Scaffold(
      appBar: AppBar(title: Text("")), // Show the selected month and year
      body: buildMonthView(date), // Call buildMonthView with the selected date
    );
  }
}

import 'package:flutter/material.dart';
import 'views/day_view.dart';
import 'views/month_view.dart';
import 'views/year_view.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedView = "Day"; // Default view is Day View
  DateTime currentDate = DateTime.now(); // Track current month and year

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule Manager")),
      body: Stack(
        children: [
          Column(
            children: [
              // Row of buttons for selecting the view
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildGridButton(
                      context: context,
                      label: "Day View",
                      icon: const Icon(
                        Icons.calendar_today,
                        color: Colors.black,
                      ),
                      onPressed: () => setState(() => selectedView = "Day"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildGridButton(
                      context: context,
                      label: "Month View",
                      icon: const Icon(
                        Icons.calendar_month,
                        color: Colors.black,
                      ),
                      onPressed: () => setState(() => selectedView = "Month"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildGridButton(
                      context: context,
                      label: "Year View",
                      icon: const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.black,
                      ),
                      onPressed: () => setState(() => selectedView = "Year"),
                    ),
                  ),
                ],
              ),
              // Expanded widget for calendar views
              Expanded(child: _buildCalendarView()),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: ElevatedButton(
              onPressed: () {
                // The button currently does nothing
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow, // Yellow color for the button
                shape: CircleBorder(),
                padding: EdgeInsets.all(20),
                shadowColor: Colors.black,
              ),
              child: Icon(Icons.add, color: Colors.black, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build different calendar views
  Widget _buildCalendarView() {
    switch (selectedView) {
      case "Day":
        return buildDayView(currentDate);
      case "Month":
        return buildMonthView(currentDate);
      case "Year":
        return YearViewPage();
      default:
        return const Text("Select a View");
    }
  }


// Build buttons
ElevatedButton _buildGridButton({
  required BuildContext context,
  required String label,
  required VoidCallback onPressed,
  Icon? icon,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      elevation: 5,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) icon,
        const SizedBox(width: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

}
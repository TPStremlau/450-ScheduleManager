import 'package:final_project/views/event_set.dart';
import 'package:flutter/material.dart';
import 'views/day_view.dart';
import 'views/month_view.dart'; // Include MonthView and other views as needed
import 'views/year_view.dart'; // Include YearView and other views as needed


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String selectedView = "Day"; // Default view is Day View

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
                EventScreenState().showEventPopup(context);
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
        // Pass current date to DayView
        return DayView(date: DateTime.now()); // Passing current date
      case "Month":
        return buildMonthView(DateTime.now()); // buildMonth view
      case "Year":
        return YearViewPage(); // Display the YearView

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
// Day View Scrollable List
  Widget buildDayView(DateTime date) {
    String currentDate = DateFormat('MMMM d, yyyy').format(date); // Get formatted date

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            currentDate,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 24, // 24 hours in a day
            itemBuilder: (context, index) {
              String time = DateFormat.jm().format(
                DateTime(0, 0, 0, index),
              ); // Format like 12:00 AM
              return Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 2),
                child: ListTile(
                  title: Text(
                    time,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    "No Events", // Placeholder for events
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: const Icon(Icons.access_time, color: Colors.black),
                  tileColor: Colors.blue.shade100,
                ),
              );
            },
          ),
        ),
    ],
    );
  }

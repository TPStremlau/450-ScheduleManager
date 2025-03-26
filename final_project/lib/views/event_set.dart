import 'package:flutter/material.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  EventScreenState createState() => EventScreenState();
}

class EventScreenState extends State<EventScreen> {
  void showEventPopup(BuildContext context) {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    TextEditingController eventNameController = TextEditingController();
    TextEditingController eventNotesController = TextEditingController();
    bool notificationsEnabled = false;
    int notificationTimeBefore = 5; // Default 5 minutes before

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "New Event",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Please enter the info below",
                      style: TextStyle(fontSize: 15),
                    ),
                    // Event Name
                    TextField(
                      controller: eventNameController,
                      decoration: InputDecoration(
                        labelText: "Event Name(Required)",
                      ),
                    ),

                    // Event Notes
                    TextField(
                      controller: eventNotesController,
                      decoration: InputDecoration(
                        labelText: "Event Notes(Optional)",
                      ),
                      maxLines: 2,
                    ),

                    // Date Picker
                    ListTile(
                      title: Text(
                        selectedDate == null
                            ? "Select Date(Required)"
                            : "Date: ${selectedDate!.toLocal()}".split(' ')[0],
                      ),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          // https://api.flutter.dev/flutter/material/showDatePicker.html
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                    ),

                    // Time Picker
                    ListTile(
                      title: Text(
                        selectedTime == null
                            ? "Select Time(Required)"
                            : "Time: ${selectedTime!.format(context)}",
                      ),
                      trailing: Icon(Icons.access_time),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );
                        if (picked != null && picked != selectedTime) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                    ),

                    // Checkbox for Notifications
                    CheckboxListTile(
                      title: Text("Enable Notifications"),
                      value: notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          notificationsEnabled = value!;
                        });
                      },
                    ),

                    // Notification Time Picker
                    if (notificationsEnabled)
                      DropdownButton<int>(
                        value: notificationTimeBefore,
                        items:
                            [5, 10, 15, 30, 60]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text("$e minutes before"),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            notificationTimeBefore = value!;
                          });
                        },
                      ),

                    // Save / Cancel Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.blue.shade100,
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            //placeholder for firebase stuff
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.blue.shade100,
                            ),
                          ),
                          child: Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  //useless code not needed ignore
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Events")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => showEventPopup(context),
          child: Text("Add Event"),
        ),
      ),
    );
  }
}

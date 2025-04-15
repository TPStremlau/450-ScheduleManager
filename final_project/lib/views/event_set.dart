
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  EventScreenState createState() => EventScreenState();
}

class EventScreenState extends State<EventScreen> {
  void showEventPopup(BuildContext context) {
    DateTime? selectedDate;
    TimeOfDay? selectedTime = TimeOfDay.now();
    TextEditingController eventNameController = TextEditingController();
    TextEditingController eventNotesController = TextEditingController();
    bool notificationsEnabled = false;
    int notificationTimeBefore = 5;
    bool isRecurring = false;
    String recurrenceFrequency = 'Daily';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "New Event",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Please enter the info below",
                      style: TextStyle(fontSize: 15),
                    ),

                    TextField(
                      controller: eventNameController,
                      decoration: const InputDecoration(
                        labelText: "Event Name (Required)",
                      ),
                    ),

                    TextField(
                      controller: eventNotesController,
                      decoration: const InputDecoration(
                        labelText: "Event Notes (Optional)",
                      ),
                      maxLines: 2,
                    ),

                    ListTile(
                      title: Text(
                        selectedDate == null
                            ? "Select Date (Required)"
                            : "Date: ${DateFormat('MMM d, yyyy').format(selectedDate!)}",
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
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

                    ListTile(
                      title: Text(
                        selectedTime == null
                            ? "Select Time (Required)"
                            : "Time: ${selectedTime!.format(context)}",
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          if (!mounted) return;
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                    ),

                    CheckboxListTile(
                      title: const Text("Enable Notifications"),
                      value: notificationsEnabled,
                      onChanged: (value) {
                        if (!mounted) return;
                        setState(() {
                          notificationsEnabled = value!;
                        });
                      },
                    ),

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

                    CheckboxListTile(
                      title: const Text("Recurring Event"),
                      value: isRecurring,
                      onChanged: (value) {
                        if (!mounted) return;
                        setState(() {
                          isRecurring = value!;
                        });
                      },
                    ),

                    if (isRecurring)
                      DropdownButton<String>(
                        value: recurrenceFrequency,
                        items:
                            ['Daily', 'Weekly', 'Monthly']
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (!mounted) return;
                          setState(() {
                            recurrenceFrequency = value!;
                          });
                        },
                      ),

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
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (eventNameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Event name is required'),
                                ),
                              );
                              return;
                            }
                            if (selectedDate == null || selectedTime == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Date and time are required'),
                                ),
                              );
                              return;
                            }

                            await saveEventToFirestore(
                              eventNameController.text,
                              eventNotesController.text,
                              selectedDate,
                              selectedTime,
                              notificationsEnabled,
                              notificationTimeBefore,
                              isRecurring,
                              recurrenceFrequency,
                            );
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Event saved successfully'),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.blue.shade100,
                            ),
                          ),
                          child: const Text(
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

  Future<void> saveEventToFirestore(
    String eventName,
    String eventNotes,
    DateTime? date,
    TimeOfDay? time,
    bool notificationsEnabled,
    int notificationTimeBefore,
    bool isRecurring,
    String recurrenceFrequency,
  ) async {
    if (eventName.isEmpty || date == null || time == null) {
      return;
    }

    // Get FCM token
   
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    // Combine Date and Time correctly
    DateTime eventDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final eventData = {
      'eventName': eventName,
      'eventNotes': eventNotes,
      'dateTime': eventDateTime.toUtc().toIso8601String(),
      'date': DateFormat('yyyy-MM-dd').format(eventDateTime), // Added this line
      'notificationsEnabled': notificationsEnabled,
      'notificationTimeBefore':
          notificationsEnabled ? notificationTimeBefore : null,
      'isRecurring': isRecurring,
      'recurrenceFrequency': isRecurring ? recurrenceFrequency : null,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('events').add(eventData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Events")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => showEventPopup(context),
          child: const Text("Add Event"),
        ),
      ),
    );
  }
}

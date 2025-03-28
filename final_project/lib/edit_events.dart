import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditEvent extends StatefulWidget {
  final Map<String, dynamic> event; // Existing event data

  const EditEvent({super.key, required this.event});

  @override
  State<EditEvent> createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late DateTime _selectedDateTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with event data
    _nameController = TextEditingController(text: widget.event['eventName']);
    _notesController = TextEditingController(text: widget.event['eventNotes']);
    _selectedDateTime = DateTime.parse(widget.event['dateTime']).toLocal();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateEvent() async {
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event['eventId']) // Use the event ID to update
          .update({
        'eventName': _nameController.text,
        'eventNotes': _notesController.text,
        'dateTime': _selectedDateTime.toUtc().toIso8601String(),
      });

      Navigator.pop(context); // Go back after saving
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully')),
      );
    } catch (e) {
      debugPrint('Error updating event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating event: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Event Name'),
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ListTile(
              title: Text('Date & Time: ${DateFormat.yMMMd().add_jm().format(_selectedDateTime)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDateTime(context),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _updateEvent,
              child: _isSaving ? const CircularProgressIndicator() : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
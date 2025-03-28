import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/edit_events.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayView extends StatefulWidget {
  final DateTime date;

  const DayView({super.key, required this.date});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  Map<int, List<Map<String, dynamic>>> eventsByHour = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
  setState(() => _isLoading = true);
  
  try {
    // Get current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle case where user is not logged in
      setState(() => _isLoading = false);
      return;
    }

    // Get events for the selected date 
    String formattedDate = DateFormat('yyyy-MM-dd').format(widget.date);
    QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('createdBy', isEqualTo: user.uid)  // Use user.uid instead of UserCredential
        .where('date', isEqualTo: formattedDate)
        .get();

    Map<int, List<Map<String, dynamic>>> tempEventsByHour = {};

    for (var doc in eventSnapshot.docs) {
      Map<String, dynamic> eventData = doc.data() as Map<String, dynamic>;
      DateTime eventDateTime = DateTime.parse(eventData['dateTime']).toLocal();
      int eventHour = eventDateTime.hour;

      if (!tempEventsByHour.containsKey(eventHour)) {
        tempEventsByHour[eventHour] = [];
      }
      tempEventsByHour[eventHour]!.add(eventData);
    }

    setState(() {
      eventsByHour = tempEventsByHour;
      _isLoading = false;
    });
  } catch (e) {
    debugPrint('Error fetching events: $e');
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading events: ${e.toString()}')),
    );
  }
}
//build each hour so we can have unlimited events per hour
  Widget _buildHourTile(int hour) {
    String timeLabel = DateFormat.jm().format(DateTime(0, 0, 0, hour));
    bool hasEvents = eventsByHour.containsKey(hour);
    List<Map<String, dynamic>> hourEvents = hasEvents ? eventsByHour[hour]! : [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        color: Colors.blue[200], //backround color
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    timeLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  if (hasEvents)
                    Chip(
                      label: Text('${hourEvents.length} event(s)', style: TextStyle(color: Colors.black),),
                      backgroundColor: Colors.white,
                    ),
                ],
              ),
              if (hasEvents) ...[
                
                Column(
                  children: hourEvents.map((event) => _buildEventItem(event)).toList(),
                ),
              ] else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No events scheduled',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
            ],
          ),
        
        ),
      ),
    );
  }

  Widget _buildEventItem(Map<String, dynamic> event) {
    DateTime eventTime = DateTime.parse(event['dateTime']).toLocal();
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event, color: Colors.black),
      title: Text(
        event['eventName'],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat.jm().format(eventTime), style: TextStyle(color: Colors.black),),
          if (event['eventNotes']?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                event['eventNotes'],
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
        ],
      ),
      onTap: () => _showEventDetails(event),
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    DateTime eventTime = DateTime.parse(event['dateTime']).toLocal();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event['eventName']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${DateFormat.yMMMd().add_jm().format(eventTime)}'),
            if (event['eventNotes']?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(event['eventNotes']),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToEditEvent(event);
            },
            child: const Text('Edit Event'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteEvent(event);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Event'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMMM d, yyyy').format(widget.date)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchEvents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: 24,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) => _buildHourTile(index),
            ),
    );
  }
  void _confirmDeleteEvent(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${event['eventName']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent(event);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvent(Map<String, dynamic> event) async {
  try {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(event['eventId']) // Ensure deletion by eventId
        .delete();

    fetchEvents(); // Refresh event list

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event deleted successfully')),
    );
  } catch (e) {
    debugPrint('Error deleting event: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error deleting event: ${e.toString()}')),
    );
  }
}

void _navigateToEditEvent(Map<String, dynamic> event) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => EditEvent(event: event)),
    );
  }
}


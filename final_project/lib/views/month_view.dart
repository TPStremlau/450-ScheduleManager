import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'day_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<DateTime>> getHolidaysForMonth(DateTime selectedDate) async {
  List<DateTime> holidays = []; // set up an empty list to store the holidays for the month 

 // DateTime firstOfMonth = DateTime.utc(selectedDate.year, selectedDate.month, 1); // find the first dateTime of the month
 // DateTime lastOfMonth = DateTime.utc(selectedDate.year, selectedDate.month + 1, 0); // find the last dateTime of the month 

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('publicHolidays') // access the collection in firebase of the public holidays 
      //.where('date', isGreaterThanOrEqualTo: firstOfMonth) // where date is greater than first of month
      //.where('date', isLessThanOrEqualTo: lastOfMonth) // and less than last of month 
      .get(); // get all these dates 
  print('Snapshot docs: ${snapshot.docs}'); 
  for (var doc in snapshot.docs) { 
    DateTime holidayDate = (doc['date'] as Timestamp).toDate().toLocal(); 
    holidays.add(holidayDate); // add any of these dates to the holidays list
  }
  print('Holidays for ${selectedDate.month}/${selectedDate.year}: $holidays');
  return holidays;
}

Widget buildMonthView(DateTime selectedDate,) {
  int daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
  int firstDayOfWeek = DateTime(selectedDate.year, selectedDate.month, 1).weekday;

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          DateFormat.yMMMM().format(selectedDate),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
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
      FutureBuilder<List<DateTime>>(
        future: getHolidaysForMonth(selectedDate), // for each date check if there is a holiday for that day in that month 
        builder: (context, snapshot) {
          if (!snapshot.hasData) { 
            return const CircularProgressIndicator(); 
          } // handles asynchronous

          List<DateTime> holidays = snapshot.data!; // stores retrieved list in holidays 
          return Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.2,
              ),
              itemCount: daysInMonth + firstDayOfWeek - 1,
              itemBuilder: (context, index) {
                if (index < firstDayOfWeek - 1) {
                  return Container();
                }
                int day = index - firstDayOfWeek + 2;
                if (day > daysInMonth) {
                  return Container();
                }
                DateTime currentDay = DateTime(selectedDate.year, selectedDate.month, day);
                  currentDay = DateTime(currentDay.year, currentDay.month, currentDay.day); 
                  print('Current day: $currentDay');

                  print('Holidays list: $holidays');  // remove time
                bool isHoliday = holidays.any((holiday){
                  holiday = DateTime(holiday.year, holiday.month, holiday.day);
                  return holiday.day == currentDay.day && holiday.month == currentDay.month;});
                  print('Is holiday: $isHoliday');
                // Pre-fetch holiday names outside itemBuilder
                Future<String> getHolidayName() async {
                  if (isHoliday) {
                    try {
                      QuerySnapshot snapshot = await FirebaseFirestore.instance
                      .collection('publicHolidays')
                      .where('date', isEqualTo: currentDay)
                      .get();
                      if (snapshot.docs.isNotEmpty) {
                        return snapshot.docs.first['name'];
                      } else {
                        return 'Holiday';
                      }
                    } catch (e) {
                      return 'Holiday';
                    }
                  }
                  return '';
                }

                return FutureBuilder<String>(
                  future: getHolidayName(),
                  builder: (context, holidayNameSnapshot) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(
                                title: Text(DateFormat.yMMMd().format(DateTime(selectedDate.year, selectedDate.month, day))),
                              ),
                              body: DayView(
                                date: DateTime(selectedDate.year, selectedDate.month, day),
                              ),
                            ),
                          ),
                        );
                      }, 
                     // problem: is never Holiday 
                      child: Card(
                        color: isHoliday ? Colors.pink.shade100 : Colors.blue.shade100, // if it is a holiday, color it red, else, blue
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "$day", 
                                style: TextStyle(
                                  fontSize: 16, 
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    ],
  );
}

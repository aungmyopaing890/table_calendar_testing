// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0
// ignore_for_file: library_private_types_in_public_api, prefer_for_elements_to_map_fromiterable

import 'dart:collection';
import 'dart:math';

import 'package:designchallenge2/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);
int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

final _kEventSource = Map.fromIterable(List.generate(50, (index) => index),
    key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
    value: (item) => List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}')))
  ..addAll({
    kToday: [
      const Event('Today\'s Event 1'),
      const Event('Today\'s Event 2'),
    ],
  });

List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          Container(
            height: 160,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: TableCalendar<Event>(
              rowHeight: 50,
              firstDay: kFirstDay,
              lastDay: kLastDay,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              calendarFormat: _calendarFormat,
              rangeSelectionMode: _rangeSelectionMode,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: HeaderStyle(
                  titleTextStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 20),
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextFormatter: (date, locale) =>
                      DateFormat.MMMM(locale).format(date),
                  leftChevronIcon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 25,
                  ),
                  rightChevronIcon: const Icon(
                    Icons.add,
                    color: blueColor,
                    size: 25,
                  )),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (BuildContext context, date, events) {
                  if (events.isEmpty) return const SizedBox();
                  return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(top: 45),
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            width: 5,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.primaries[
                                    Random().nextInt(Colors.primaries.length)]),
                          ),
                        );
                      });
                },
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                markersOffset: const PositionedOffset(),
                markersMaxCount: 5,
                canMarkersOverflow: false,
                markerDecoration: BoxDecoration(
                    color: Colors
                        .primaries[Random().nextInt(Colors.primaries.length)],
                    borderRadius: BorderRadius.circular(50)),
                todayTextStyle: const TextStyle(color: Colors.black),
                todayDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey, width: 0.1)),
                holidayDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey, width: 0.1)),
                disabledDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey, width: 0.1)),
                defaultDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey, width: 0.1)),
                selectedDecoration: BoxDecoration(
                    border: Border.all(color: blueColor, width: 0.1),
                    color: blueColor,
                    borderRadius: BorderRadius.circular(5)),
                weekendDecoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.1),
                    borderRadius: BorderRadius.circular(5)),
                outsideDecoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.1),
                    borderRadius: BorderRadius.circular(5)),
                outsideTextStyle: const TextStyle(color: Colors.black),
              ),
              onDaySelected: _onDaySelected,
              onRangeSelected: _onRangeSelected,
              onFormatChanged: (format) {},
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        title: Text('${value[index]}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}







// import 'package:flutter/material.dart';

// class HomeView extends StatelessWidget {
//   const HomeView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return (Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(
//               Icons.arrow_back_ios,
//               size: 20.0,
//               color: Colors.black,
//             ),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           toolbarHeight: 60,
//           title: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const SizedBox(
//                     width: 1,
//                   ),
//                   const Text("July",
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 20,
//                       )),
//                   Ink(
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(13.0),
//                       onTap: () {},
//                       child: const Padding(
//                           padding: EdgeInsets.all(10.0),
//                           child: Icon(
//                             Icons.add,
//                             color: Colors.blue,
//                           )),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           centerTitle: true,
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           iconTheme: const IconThemeData(color: Colors.black),
//         ),
//         body: Column()));
//   }
// }

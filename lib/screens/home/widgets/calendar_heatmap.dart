import 'package:flutter/material.dart';
import 'package:libraryapp/models/borrowed_books.dart';

class CalendarHeatmap extends StatefulWidget {
  final List<BorrowedBooks> books;

  const CalendarHeatmap({super.key, required this.books});

  @override
  State<CalendarHeatmap> createState() => _CalendarHeatmapState();
}

class _CalendarHeatmapState extends State<CalendarHeatmap> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to current month after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMonth();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentMonth() {
    final now = DateTime.now();
    final oneYearAgo = DateTime(now.year - 1, now.month, now.day);
    
    // Calculate which month index we're at
    int monthsFromStart = (now.year - oneYearAgo.year) * 12 + (now.month - oneYearAgo.month);
    
    // Calculate approximate width per month (average ~5 weeks per month * 14px per week + 8px spacing)
    const double averageMonthWidth = (5 * 14.0) + 8.0;
    final double scrollPosition = monthsFromStart * averageMonthWidth;
    
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final oneYearAgo = DateTime(now.year - 1, now.month, now.day);
    
    // Create a map of dates to activities
    final Map<String, List<String>> dateActivities = {};
    
    for (var book in widget.books) {
      if (book.borrowedDate != null) {
        final dateKey = _dateKey(book.borrowedDate!);
        dateActivities.putIfAbsent(dateKey, () => []).add('borrowed');
      }
      if (book.dueDate != null) {
        final dateKey = _dateKey(book.dueDate!);
        dateActivities.putIfAbsent(dateKey, () => []).add('return');
      }
    }

    // Calculate intensity levels (for green shading like GitHub)
    final Map<String, int> dateIntensity = {};
    for (var entry in dateActivities.entries) {
      dateIntensity[entry.key] = entry.value.length;
    }

    // Build calendar by month
    final List<Widget> monthWidgets = [];
    DateTime currentMonth = DateTime(oneYearAgo.year, oneYearAgo.month, 1);
    final nowMonth = DateTime(now.year, now.month, 1);
    
    while (currentMonth.isBefore(nowMonth) || currentMonth.isAtSameMomentAs(nowMonth)) {
      // Calculate days in this month
      final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
      final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
      
      // Find the Sunday before or on the first day of the month
      DateTime weekStart = firstDayOfMonth;
      while (weekStart.weekday != DateTime.sunday) {
        weekStart = weekStart.subtract(const Duration(days: 1));
      }
      
      // Calculate number of weeks needed for this month
      final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month, daysInMonth);
      DateTime weekEnd = weekStart;
      int weeksInMonth = 0;
      
      while (weekEnd.isBefore(lastDayOfMonth) || weekEnd.isAtSameMomentAs(lastDayOfMonth)) {
        weeksInMonth++;
        weekEnd = weekEnd.add(const Duration(days: 7));
      }
      
      // Build week columns for this month
      final List<List<Widget>> monthWeekColumns = [];
      DateTime weekDate = weekStart;
      
      for (int week = 0; week < weeksInMonth; week++) {
        final List<Widget> weekDays = [];
        
        for (int day = 0; day < 7; day++) {
          final date = weekDate.add(Duration(days: day));
          final dateKey = _dateKey(date);
          final activities = dateActivities[dateKey] ?? [];
          final intensity = dateIntensity[dateKey] ?? 0;
          final isToday = _isSameDay(date, now);
          final isCurrentMonth = date.month == currentMonth.month && date.year == currentMonth.year;
          
          Color cellColor = const Color(0xFFEBEDF0); // Default grey
          
          // Only show activity colors for days in current month
          if (activities.isNotEmpty && isCurrentMonth) {
            if (activities.contains('borrowed') && activities.contains('return')) {
              if (intensity >= 3) {
                cellColor = Colors.orange.shade400;
              } else if (intensity == 2) {
                cellColor = Colors.orange.shade300;
              } else {
                cellColor = Colors.orange.shade200;
              }
            } else if (activities.contains('return')) {
              if (intensity >= 3) {
                cellColor = Colors.red.shade400;
              } else if (intensity == 2) {
                cellColor = Colors.red.shade300;
              } else {
                cellColor = Colors.red.shade200;
              }
            } else {
              if (intensity >= 3) {
                cellColor = const Color(0xFF196127);
              } else if (intensity == 2) {
                cellColor = const Color(0xFF239A3B);
              } else {
                cellColor = const Color(0xFF7BC96F);
              }
            }
          } else if (!isCurrentMonth) {
            // Make days from other months more subtle
            cellColor = const Color(0xFFF5F5F5);
          }
          
          weekDays.add(
            Container(
              width: 11,
              height: 11,
              margin: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: cellColor,
                borderRadius: BorderRadius.circular(2),
                border: isToday ? Border.all(color: Colors.blue, width: 1) : null,
              ),
            ),
          );
        }
        
        monthWeekColumns.add(weekDays);
        weekDate = weekDate.add(const Duration(days: 7));
      }
      
      // Add month widget
      monthWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month label
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                _getShortMonthName(currentMonth.month),
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ),
            // Week columns for this month
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: monthWeekColumns.map((week) {
                return Column(children: week);
              }).toList(),
            ),
          ],
        ),
      );
      
      // Add spacing between months
      monthWidgets.add(const SizedBox(width: 8));
      
      // Move to next month
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendar grid with day labels
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels (Mon, Wed, Fri only like GitHub)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 25), // Space for month labels
                SizedBox(height: 11 + 3), // First day (Sun) - hidden
                SizedBox(
                  height: 11 + 3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text('Mon', style: TextStyle(fontSize: 9, color: Colors.grey[600])),
                    ),
                  ),
                ),
                SizedBox(height: 11 + 3), // Tue - hidden
                SizedBox(
                  height: 11 + 3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text('Wed', style: TextStyle(fontSize: 9, color: Colors.grey[600])),
                    ),
                  ),
                ),
                SizedBox(height: 11 + 3), // Thu - hidden
                SizedBox(
                  height: 11 + 3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text('Fri', style: TextStyle(fontSize: 9, color: Colors.grey[600])),
                    ),
                  ),
                ),
                SizedBox(height: 11 + 3), // Sat - hidden
              ],
            ),
            // Scrollable calendar with months
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: monthWidgets,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getShortMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

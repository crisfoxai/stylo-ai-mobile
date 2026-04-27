import 'package:device_calendar/device_calendar.dart';

class CalendarEventContext {
  final String title;
  final String startTime;
  final bool isAllDay;

  const CalendarEventContext({
    required this.title,
    required this.startTime,
    required this.isAllDay,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'startTime': startTime,
        'isAllDay': isAllDay,
      };
}

class CalendarService {
  final _plugin = DeviceCalendarPlugin();

  Future<List<CalendarEventContext>> getTodayEvents() async {
    try {
      final permResult = await _plugin.requestPermissions();
      if (permResult.data != true) return [];

      final calsResult = await _plugin.retrieveCalendars();
      final Iterable<Calendar> calendars = calsResult.data ?? <Calendar>[];

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final events = <CalendarEventContext>[];

      for (final cal in calendars) {
        if (cal.id == null) continue;
        final eventsResult = await _plugin.retrieveEvents(
          cal.id!,
          RetrieveEventsParams(startDate: startOfDay, endDate: endOfDay),
        );
        final eventsData = eventsResult.data;
        if (eventsData == null) continue;
        for (final Event e in eventsData) {
          events.add(CalendarEventContext(
            title: e.title ?? 'Evento',
            startTime: e.start?.toIso8601String() ?? now.toIso8601String(),
            isAllDay: e.allDay ?? false,
          ));
        }
      }

      return events;
    } catch (_) {
      return [];
    }
  }
}

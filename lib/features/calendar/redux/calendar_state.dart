class CalendarState {
  final List<dynamic> events;
  final bool isLoading;

  CalendarState({required this.events, required this.isLoading});

  factory CalendarState.initial() => CalendarState(events: [], isLoading: false);

  CalendarState copyWith({List<dynamic>? events, bool? isLoading}) {
    return CalendarState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

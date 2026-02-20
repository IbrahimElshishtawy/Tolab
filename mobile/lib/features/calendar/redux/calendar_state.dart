class CalendarState {
  final bool isLoading;
  CalendarState({required this.isLoading});
  factory CalendarState.initial() => CalendarState(isLoading: false);
}

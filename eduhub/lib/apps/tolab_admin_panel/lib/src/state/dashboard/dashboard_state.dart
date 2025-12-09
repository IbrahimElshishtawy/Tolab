class DashboardStats {
  final bool isLoading;
  final int totalStudents;
  final int totalDoctors;
  final int totalSubjects;
  final int pendingRequests;
  final List<String> recentActivity;
  final String? error;

  DashboardStats({
    required this.isLoading,
    required this.totalStudents,
    required this.totalDoctors,
    required this.totalSubjects,
    required this.pendingRequests,
    required this.recentActivity,
    this.error,
  });

  factory DashboardStats.initial() {
    return DashboardStats(
      isLoading: false,
      totalStudents: 0,
      totalDoctors: 0,
      totalSubjects: 0,
      pendingRequests: 0,
      recentActivity: [],
      error: null,
    );
  }

  DashboardStats copyWith({
    bool? isLoading,
    int? totalStudents,
    int? totalDoctors,
    int? totalSubjects,
    int? pendingRequests,
    List<String>? recentActivity,
    String? error,
  }) {
    return DashboardStats(
      isLoading: isLoading ?? this.isLoading,
      totalStudents: totalStudents ?? this.totalStudents,
      totalDoctors: totalDoctors ?? this.totalDoctors,
      totalSubjects: totalSubjects ?? this.totalSubjects,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      recentActivity: recentActivity ?? this.recentActivity,
      error: error,
    );
  }
}

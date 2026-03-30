import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../state/app_state.dart';
import '../models/content_models.dart';
import 'content_state.dart';

class ContentDashboardMetrics {
  const ContentDashboardMetrics({
    required this.totalContent,
    required this.totalAssessments,
    required this.pendingSubmissions,
    required this.averageEngagementRate,
  });

  final int totalContent;
  final int totalAssessments;
  final int pendingSubmissions;
  final double averageEngagementRate;
}

ContentState contentStateOf(AppState state) => state.contentState;

List<ContentRecord> selectAllContent(ContentState state) {
  return state.orderedIds
      .map((id) => state.entities[id])
      .whereType<ContentRecord>()
      .toList(growable: false);
}

List<ContentRecord> selectFilteredContent(ContentState state) {
  final query = state.filters.searchQuery.trim().toLowerCase();
  return selectAllContent(state)
      .where((item) {
        final matchesQuery =
            query.isEmpty ||
            item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query) ||
            item.subject.title.toLowerCase().contains(query) ||
            item.subject.code.toLowerCase().contains(query) ||
            item.instructor.name.toLowerCase().contains(query);
        final matchesType =
            state.filters.type == null || item.type == state.filters.type;
        final matchesSubject =
            state.filters.subjectId == null ||
            item.subject.id == state.filters.subjectId;
        final matchesInstructor =
            state.filters.instructorId == null ||
            item.instructor.id == state.filters.instructorId;
        final matchesStatus =
            state.filters.status == null || item.status == state.filters.status;
        return matchesQuery &&
            matchesType &&
            matchesSubject &&
            matchesInstructor &&
            matchesStatus;
      })
      .toList(growable: false);
}

List<ContentRecord> selectSortedContent(ContentState state) {
  final sorted = [...selectFilteredContent(state)];
  sorted.sort((left, right) {
    final direction = state.sort.ascending ? 1 : -1;
    final comparison = switch (state.sort.field) {
      ContentSortField.title => left.title.compareTo(right.title),
      ContentSortField.publishDate =>
        (left.publishAt ?? left.createdAt).compareTo(
          right.publishAt ?? right.createdAt,
        ),
      ContentSortField.dueDate => (left.dueAt ?? left.updatedAt).compareTo(
        right.dueAt ?? right.updatedAt,
      ),
      ContentSortField.submissions => left.submittedCount.compareTo(
        right.submittedCount,
      ),
      ContentSortField.engagement => left.viewCount.compareTo(right.viewCount),
    };
    return comparison * direction;
  });
  return List<ContentRecord>.unmodifiable(sorted);
}

List<ContentRecord> selectVisibleContent(ContentState state) {
  final sorted = selectSortedContent(state);
  final start = math.min(
    sorted.length,
    math.max(0, state.pagination.page - 1) * state.pagination.perPage,
  );
  final end = math.min(sorted.length, start + state.pagination.perPage);
  return List<ContentRecord>.unmodifiable(sorted.sublist(start, end));
}

int selectTotalPages(ContentState state) {
  final total = selectFilteredContent(state).length;
  if (total == 0) return 1;
  return (total / state.pagination.perPage).ceil();
}

ContentRecord? selectActiveContent(ContentState state) {
  return state.entities[state.selectedContentId] ??
      selectVisibleContent(state).firstOrNull;
}

bool selectAreAllVisibleSelected(ContentState state) {
  final visibleIds = selectVisibleContent(state).map((item) => item.id).toSet();
  if (visibleIds.isEmpty) return false;
  return visibleIds.every(state.selectedIds.contains);
}

ContentDashboardMetrics selectDashboardMetrics(ContentState state) {
  final items = selectAllContent(state);
  if (items.isEmpty) {
    return const ContentDashboardMetrics(
      totalContent: 0,
      totalAssessments: 0,
      pendingSubmissions: 0,
      averageEngagementRate: 0,
    );
  }
  final totalAssessments = items
      .where(
        (item) =>
            item.type == ContentType.quiz ||
            item.type == ContentType.task ||
            item.type == ContentType.exam,
      )
      .length;
  final pendingSubmissions = items.fold<int>(
    0,
    (sum, item) => sum + item.pendingCount,
  );
  final averageEngagementRate =
      items.fold<double>(0, (sum, item) => sum + item.engagementRate) /
      items.length;
  return ContentDashboardMetrics(
    totalContent: items.length,
    totalAssessments: totalAssessments,
    pendingSubmissions: pendingSubmissions,
    averageEngagementRate: averageEngagementRate,
  );
}

List<ContentActivityItem> selectRecentActivity(ContentState state) {
  final items = selectAllContent(state).expand((item) => item.activity).toList()
    ..sort((left, right) => right.timestamp.compareTo(left.timestamp));
  return items.take(6).toList(growable: false);
}

List<ContentUploadTask> selectUploadTasks(ContentState state) {
  return state.uploadTasks.values.toList(growable: false)
    ..sort((left, right) => right.source.name.compareTo(left.source.name));
}

bool selectHasPendingUploads(ContentState state) {
  return state.uploadTasks.values.any(
    (task) => task.isQueued || task.isUploading,
  );
}

Color selectStatusColor(ContentStatus status) {
  return switch (status) {
    ContentStatus.draft => AppColors.warning,
    ContentStatus.published => AppColors.secondary,
    ContentStatus.scheduled => AppColors.info,
    ContentStatus.archived => AppColors.danger,
  };
}

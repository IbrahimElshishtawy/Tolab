import 'dart:collection';

import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../state/app_state.dart';
import '../models/department_models.dart';

class DepartmentsState {
  const DepartmentsState({
    this.status = LoadStatus.initial,
    this.mutationStatus = LoadStatus.initial,
    this.items = const <DepartmentRecord>[],
    this.filters = const DepartmentFilters(),
    this.sort = const DepartmentsSort(),
    this.pagination = const DepartmentsPagination(),
    this.selectedIds = const <String>{},
    this.selectedDepartmentId,
    this.activeTab = DepartmentDetailTab.overview,
    this.errorMessage,
    this.mutationMessage,
  });

  final LoadStatus status;
  final LoadStatus mutationStatus;
  final List<DepartmentRecord> items;
  final DepartmentFilters filters;
  final DepartmentsSort sort;
  final DepartmentsPagination pagination;
  final Set<String> selectedIds;
  final String? selectedDepartmentId;
  final DepartmentDetailTab activeTab;
  final String? errorMessage;
  final String? mutationMessage;

  UnmodifiableListView<DepartmentRecord> get immutableItems =>
      UnmodifiableListView(items);

  DepartmentsState copyWith({
    LoadStatus? status,
    LoadStatus? mutationStatus,
    List<DepartmentRecord>? items,
    DepartmentFilters? filters,
    DepartmentsSort? sort,
    DepartmentsPagination? pagination,
    Set<String>? selectedIds,
    String? selectedDepartmentId,
    bool clearSelectedDepartmentId = false,
    DepartmentDetailTab? activeTab,
    String? errorMessage,
    bool clearError = false,
    String? mutationMessage,
    bool clearMutationMessage = false,
  }) {
    return DepartmentsState(
      status: status ?? this.status,
      mutationStatus: mutationStatus ?? this.mutationStatus,
      items: List<DepartmentRecord>.unmodifiable(items ?? this.items),
      filters: filters ?? this.filters,
      sort: sort ?? this.sort,
      pagination: pagination ?? this.pagination,
      selectedIds: Set<String>.unmodifiable(selectedIds ?? this.selectedIds),
      selectedDepartmentId: clearSelectedDepartmentId
          ? null
          : selectedDepartmentId ?? this.selectedDepartmentId,
      activeTab: activeTab ?? this.activeTab,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      mutationMessage: clearMutationMessage
          ? null
          : mutationMessage ?? this.mutationMessage,
    );
  }
}

const DepartmentsState initialDepartmentsState = DepartmentsState();

class LoadDepartmentsAction {
  const LoadDepartmentsAction({this.silent = false});

  final bool silent;
}

class DepartmentsLoadedAction {
  const DepartmentsLoadedAction(this.items);

  final List<DepartmentRecord> items;
}

class DepartmentsFailedAction {
  const DepartmentsFailedAction(this.message);

  final String message;
}

class DepartmentFiltersChangedAction {
  const DepartmentFiltersChangedAction(this.filters);

  final DepartmentFilters filters;
}

class DepartmentSortChangedAction {
  const DepartmentSortChangedAction(this.sort);

  final DepartmentsSort sort;
}

class DepartmentPaginationChangedAction {
  const DepartmentPaginationChangedAction(this.pagination);

  final DepartmentsPagination pagination;
}

class DepartmentSelectionToggledAction {
  const DepartmentSelectionToggledAction({
    required this.departmentId,
    required this.selected,
  });

  final String departmentId;
  final bool selected;
}

class DepartmentVisibleSelectionChangedAction {
  const DepartmentVisibleSelectionChangedAction({
    required this.visibleIds,
    required this.selected,
  });

  final Set<String> visibleIds;
  final bool selected;
}

class DepartmentSelectionClearedAction {
  const DepartmentSelectionClearedAction();
}

class SelectDepartmentAction {
  const SelectDepartmentAction(this.departmentId);

  final String? departmentId;
}

class DepartmentTabChangedAction {
  const DepartmentTabChangedAction(this.tab);

  final DepartmentDetailTab tab;
}

class CreateDepartmentRequestedAction {
  const CreateDepartmentRequestedAction(this.payload);

  final DepartmentUpsertPayload payload;
}

class UpdateDepartmentRequestedAction {
  const UpdateDepartmentRequestedAction({
    required this.departmentId,
    required this.payload,
  });

  final String departmentId;
  final DepartmentUpsertPayload payload;
}

class ToggleDepartmentActivationRequestedAction {
  const ToggleDepartmentActivationRequestedAction({
    required this.departmentIds,
    required this.isActive,
  });

  final Set<String> departmentIds;
  final bool isActive;
}

class ArchiveDepartmentsRequestedAction {
  const ArchiveDepartmentsRequestedAction(this.departmentIds);

  final Set<String> departmentIds;
}

class DepartmentMutationStartedAction {
  const DepartmentMutationStartedAction();
}

class DepartmentMutationCompletedAction {
  const DepartmentMutationCompletedAction(this.result);

  final DepartmentMutationResult result;
}

class DepartmentMutationFailedAction {
  const DepartmentMutationFailedAction(this.message);

  final String message;
}

class ResetDepartmentMutationAction {
  const ResetDepartmentMutationAction();
}

DepartmentsState departmentsReducer(DepartmentsState state, dynamic action) {
  switch (action) {
    case LoadDepartmentsAction():
      return state.copyWith(
        status: action.silent ? state.status : LoadStatus.loading,
        clearError: true,
      );
    case DepartmentsLoadedAction():
      final selectedDepartmentId = state.selectedDepartmentId;
      final hasSelected = action.items.any(
        (department) => department.id == selectedDepartmentId,
      );
      return state.copyWith(
        status: LoadStatus.success,
        items: action.items,
        selectedDepartmentId: hasSelected
            ? selectedDepartmentId
            : action.items.isEmpty
            ? null
            : action.items.first.id,
        clearError: true,
      );
    case DepartmentsFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    case DepartmentFiltersChangedAction():
      return state.copyWith(
        filters: action.filters,
        pagination: state.pagination.copyWith(page: 1),
      );
    case DepartmentSortChangedAction():
      return state.copyWith(
        sort: action.sort,
        pagination: state.pagination.copyWith(page: 1),
      );
    case DepartmentPaginationChangedAction():
      return state.copyWith(pagination: action.pagination);
    case DepartmentSelectionToggledAction():
      final nextSelected = Set<String>.from(state.selectedIds);
      if (action.selected) {
        nextSelected.add(action.departmentId);
      } else {
        nextSelected.remove(action.departmentId);
      }
      return state.copyWith(selectedIds: nextSelected);
    case DepartmentVisibleSelectionChangedAction():
      final nextSelected = Set<String>.from(state.selectedIds);
      if (action.selected) {
        nextSelected.addAll(action.visibleIds);
      } else {
        nextSelected.removeAll(action.visibleIds);
      }
      return state.copyWith(selectedIds: nextSelected);
    case DepartmentSelectionClearedAction():
      return state.copyWith(selectedIds: const <String>{});
    case SelectDepartmentAction():
      return state.copyWith(selectedDepartmentId: action.departmentId);
    case DepartmentTabChangedAction():
      return state.copyWith(activeTab: action.tab);
    case DepartmentMutationStartedAction():
      return state.copyWith(
        mutationStatus: LoadStatus.loading,
        clearMutationMessage: true,
      );
    case DepartmentMutationCompletedAction():
      final selectedDepartmentId =
          action.result.selectedDepartmentId ?? state.selectedDepartmentId;
      return state.copyWith(
        items: action.result.items,
        mutationStatus: LoadStatus.success,
        mutationMessage: action.result.message,
        selectedDepartmentId: selectedDepartmentId,
        selectedIds: const <String>{},
      );
    case DepartmentMutationFailedAction():
      return state.copyWith(
        mutationStatus: LoadStatus.failure,
        mutationMessage: action.message,
      );
    case ResetDepartmentMutationAction():
      return state.copyWith(
        mutationStatus: LoadStatus.initial,
        clearMutationMessage: true,
      );
    default:
      return state;
  }
}

List<Middleware<AppState>> createDepartmentsMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoadDepartmentsAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final items = await deps.departmentsRepository.fetchDepartments();
        store.dispatch(DepartmentsLoadedAction(items));
      } catch (error) {
        store.dispatch(DepartmentsFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, CreateDepartmentRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const DepartmentMutationStartedAction());
      try {
        final result = await deps.departmentsRepository.createDepartment(
          action.payload,
        );
        store.dispatch(DepartmentMutationCompletedAction(result));
      } catch (error) {
        store.dispatch(DepartmentMutationFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, UpdateDepartmentRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const DepartmentMutationStartedAction());
      try {
        final result = await deps.departmentsRepository.updateDepartment(
          departmentId: action.departmentId,
          payload: action.payload,
        );
        store.dispatch(DepartmentMutationCompletedAction(result));
      } catch (error) {
        store.dispatch(DepartmentMutationFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, ToggleDepartmentActivationRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const DepartmentMutationStartedAction());
      try {
        final result = await deps.departmentsRepository.setActivation(
          departmentIds: action.departmentIds,
          isActive: action.isActive,
        );
        store.dispatch(DepartmentMutationCompletedAction(result));
      } catch (error) {
        store.dispatch(DepartmentMutationFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, ArchiveDepartmentsRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const DepartmentMutationStartedAction());
      try {
        final result = await deps.departmentsRepository.archiveDepartments(
          action.departmentIds,
        );
        store.dispatch(DepartmentMutationCompletedAction(result));
      } catch (error) {
        store.dispatch(DepartmentMutationFailedAction(error.toString()));
      }
    }).call,
  ];
}

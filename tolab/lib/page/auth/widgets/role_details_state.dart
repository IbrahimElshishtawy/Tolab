// lib/cubit/role_details_state.dart
import 'package:meta/meta.dart';

@immutable
abstract class RoleDetailsState {}

class RoleDetailsInitial extends RoleDetailsState {}

class RoleDetailsLoading extends RoleDetailsState {}

class RoleDetailsSuccess extends RoleDetailsState {}

class RoleDetailsError extends RoleDetailsState {
  final String message;
  RoleDetailsError(this.message);
}

part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class NotificationsStatusChanged extends NotificationsEvent {
  final AuthorizationStatus status;

  const NotificationsStatusChanged({required this.status});
}

class NotificationReceived extends NotificationsEvent {
  final PushMessage message;

  const NotificationReceived({required this.message});
}

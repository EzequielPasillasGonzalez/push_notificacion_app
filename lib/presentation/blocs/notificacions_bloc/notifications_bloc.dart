import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:push_app/config/local_notifications/local_notifications.dart';
import 'package:push_app/domain/entities/push_message.dart';
import 'package:push_app/firebase_options.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_app/helpers/helpers.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  int pushMessageIdCounter = 0;

  final Future<void> Function() requestLocalNotificationPermission;
  final void Function({
    required int id,
    String? title,
    String? body,
    String? data,
  })
  showLocalNotification;

  NotificationsBloc({
    required this.requestLocalNotificationPermission,
    required this.showLocalNotification,
  }) : super(NotificationsState()) {
    on<NotificationsStatusChanged>(_notificacionStatusChanged);

    on<NotificationReceived>(_onPushMessage);

    // Verificar estado de las notificaciones
    _initialStatusCheck();
    // Listener para notificaciones en Foreground (App abierta)
    _onForegroundMessagge();
  }

  static Future<void> initializeFirebaseNotifications() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void _notificacionStatusChanged(
    NotificationsStatusChanged event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(status: event.status));
    _getFCMToken();
  }

  void _onPushMessage(
    NotificationReceived event,
    Emitter<NotificationsState> emit,
  ) {
    emit(
      state.copyWith(notifications: [event.message, ...state.notifications]),
    );
  }

  void _initialStatusCheck() async {
    final settings = await messaging.getNotificationSettings();

    add(NotificationsStatusChanged(status: settings.authorizationStatus));
  }

  void _getFCMToken() async {
    if (state.status != AuthorizationStatus.authorized) return;

    final token = await messaging.getToken();
    print(token);
  }

  void handleRemoteMessage(RemoteMessage message) {
    if (message.notification == null) return;

    final notification = PushMessage(
      messageId: message.messageId != null
          ? CleanMessageId.clean(message.messageId!)
          : '',
      title: message.notification!.title ?? '',
      body: message.notification!.body ?? '',
      sentDate: message.sentTime ?? DateTime.now(),
      data: message.data,
      imageUrl: Platform.isAndroid
          ? message.notification!.android?.imageUrl
          : message.notification!.apple?.imageUrl,
    );

    // Muestra la notificacion push
    showLocalNotification(
      id: pushMessageIdCounter++,
      title: notification.title,
      body: notification.body,
      data: notification.messageId,
    );

    add(NotificationReceived(message: notification));
  }

  void _onForegroundMessagge() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    // Solicitar permisos a las notificaciones locales
    await requestLocalNotificationPermission();

    add(NotificationsStatusChanged(status: settings.authorizationStatus));
  }

  PushMessage? getMessageByID(String pushMessageId) {
    final exist = state.notifications.any(
      (element) => element.messageId == pushMessageId,
    );

    if (!exist) return null;

    return state.notifications.firstWhere(
      (element) => element.messageId == pushMessageId,
    );
  }
}

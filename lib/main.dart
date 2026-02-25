import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:push_app/config/local_notifications/local_notifications.dart';
import 'package:push_app/config/router/app_router.dart';
import 'package:push_app/config/theme/app_theme.dart';
import 'package:push_app/helpers/helpers.dart';
import 'package:push_app/presentation/blocs/notificacions_bloc/notifications_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await NotificationsBloc.initializeFirebaseNotifications();
  await LocalNotifications.initializeLocalNotifications();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => NotificationsBloc(
            // Se manda la referencia a la funcion para solicitar permisos
            requestLocalNotificationPermission:
                LocalNotifications.requesPermissionLocaNotifications,
            showLocalNotification: LocalNotifications.showLocalNotification,
          ),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      routerConfig: appRouter,
      builder: (context, child) =>
          HandleNotificationInteractions(child: child!),
    );
  }
}

class HandleNotificationInteractions extends StatefulWidget {
  final Widget child;
  const HandleNotificationInteractions({super.key, required this.child});

  @override
  State<HandleNotificationInteractions> createState() =>
      _HandleNotificationInteractionsState();
}

class _HandleNotificationInteractionsState
    extends State<HandleNotificationInteractions> {
  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    //  Configurar el listener para cuando la app está en BACKGROUND y se abre al tocar la notificación.
    // ESTO DEBE EJECUTARSE SIEMPRE, no puede depender de si hay un initialMessage.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // Obtener el mensaje si la app estaba TERMINADA (Cerrada completamente).
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    // Si hay un mensaje inicial, lo manejamos.
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (!mounted) return;
    
    context.read<NotificationsBloc>().handleRemoteMessage(message);

    final messageId = message.messageId != null
        ? CleanMessageId.clean(message.messageId!)
        : null;

    if (messageId == null) return;

    appRouter.push('/push-details/$messageId');
  }

  @override
  void initState() {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

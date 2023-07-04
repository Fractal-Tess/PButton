import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import './notification.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black87),
        useMaterial3: true,
      ),
      home: const Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  var uri = "192.168.0.129";
  var state = "Disconnected";
  IOWebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    Noti.initialize(flutterLocalNotificationsPlugin);
  }

  @override
  void dispose() {
    super.dispose();
    _channel?.sink.close();
  }

  setupListener() {
    _channel?.stream.listen((event) {
      print("Got event ${event.toString()}");

      flutterLocalNotificationsPlugin.show(
          0,
          "PButton",
          "Button pressed",
          const NotificationDetails(
              android: AndroidNotificationDetails(
                  "Button pressed", "notification_channel",
                  playSound: true,
                  // sound: RawResourceAndroidNotificationSound("notification"),
                  importance: Importance.high,
                  priority: Priority.high)));
    });
  }

  connect() async {
    _channel?.sink.close();
    setState(() {
      state = "Disconnected";
    });
    // socket = WebSocketChannel.connect(Uri.parse('ws://' + uri + "/ws"));
    await _channel?.sink.close();
    WebSocket.connect('ws://$uri/ws')
        .timeout(const Duration(seconds: 1))
        .then((ws) {
      try {
        _channel = IOWebSocketChannel(ws);
        setupListener();
        setState(() {
          state = "Connected";
        });
      } catch (e) {
        print('Error while trying to connect to websocket');
        print(e);
      }

      setState(() {
        state = "Connected";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("PButton"),
          backgroundColor: const Color.fromARGB(255, 13, 204, 204)),
      body: Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(state),
                TextField(
                  onChanged: (val) => setState(() {
                    uri = val;
                  }),
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: "Ip adress"),
                ),
                ElevatedButton(
                    onPressed: connect,
                    child: const Padding(
                        padding: EdgeInsets.all(16.0), child: Text("Connect")))
              ],
            )),
      ),
    );
  }
}

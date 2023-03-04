import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

void main() async {
  // initialize
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  @override
  _MainApp createState() => _MainApp();
}

class _MainApp extends State<MainApp> {
  var counter = 1;
  late FirebaseMessaging fcm;
  final FlutterLocalNotificationsPlugin flnp = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    countTime();
  }

  void countTime() async {
    fcm = FirebaseMessaging.instance;

    for (var i = 0; i < 60; i++) {
      if (counter % 6 == 0) {
        fcm.getToken().then((value) {
          debugPrint(value);
          sendNotif(value!, counter);
        });

        FirebaseMessaging.onMessage.listen((event) async {
          // show pop up notif
          await flnp.initialize(const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher')));
          flnp.show(event.hashCode, event.notification!.title, event.notification!.body, 
            const NotificationDetails(android: AndroidNotificationDetails('high', 'high')));
          
          //print("msg  :  ${event.notification!.body}");
        });
        /*await flnp.initialize(const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher')));
          flnp.show(1, 'counter', counter.toString(), 
            const NotificationDetails(android: AndroidNotificationDetails('high', 'high')));*/
      }

      await Future.delayed(const Duration(seconds: 5));

      setState(() {   
        counter++;
      });
      //debugPrint(counter.toString());
    }
  }

  Future<void> sendNotif(String token, int count) async {
    await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
      body: json.encode({
        "to" : token,
        "priority" : "high",
        "notification" : {
          "title": 'Counter',
          "body" : '$count',
        }
      }),
      encoding: Encoding.getByName('utf-8'),
      headers: {
        'content-type': 'application/json',
        'Authorization': 'key=AAAAqfc0BlU:APA91bEMKzm2ICfa7H2DhkH2vtzneMj8gccajWCbApj9BuQlFAx-CDNZ8OQIx_fLNdj9juUaZVHKhJ5MveKXHIxdaQz4L31aOavKRHYip-CZgQjJnGntVfZwI9ObVm5DaGwBiSW-OM4y'
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child:
            Text(counter.toString(), style: const TextStyle(fontSize: 50)),
        ),
      ),
    );
  }
}

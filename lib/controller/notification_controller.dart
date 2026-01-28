import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/state_manager.dart';

class NotificationController extends GetxController {
  //TO REQUEST NOTIFICATION PERMISSION FROM USER
  void requestPushPermission() async {
    await FirebaseMessaging.instance.subscribeToTopic('all');

    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('Notification permission granted !');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('Provisional Notification permission granted !');
    } else {
      log('Notification permission Declined or not Accepted !');
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Rx<String> pushToken = "".obs;

  void getPushToken() async {
    await FirebaseMessaging.instance
        .getToken()
        .then((token) {
          pushToken.value = token!;
        })
        .then((_) {
          log("Push Token: ${pushToken.value}");
          _firestore.collection("Users").doc(_auth.currentUser!.uid).set({
            "push_token": pushToken.value,

            "last_login": Timestamp.now(),
          }, SetOptions(merge: true));

          log('Updated Device and Push Token');
        });
  }
}

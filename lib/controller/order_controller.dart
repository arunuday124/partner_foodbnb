// import 'dart:developer';
// import 'package:get/get.dart';

// class OrderController extends GetxController {
//   Future<void> aceptOrder(Map orderData) async {
//     try {
     
//     } catch (e) {
//       log('accept_orders exception : $e');
//     }
//   }

//   Future<void> rejectOrder(Map orderData) async {
//     try {} catch (e) {
//       log('accept_orders exception : $e');
//     }
//   }
// }
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> aceptOrder(Map orderData) async {
    try {
      final String docId = orderData['order_id'];

      await _firestore.collection('orders').doc(docId).update({
        "orderStatus": "accepted",
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log("Accept order error: $e");
    }
  }

  Future<void> rejectOrder(Map orderData) async {
    try {
      final String docId = orderData['order_id'];

      await _firestore.collection('orders').doc(docId).update({
        "orderStatus": "rejected",
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log("Reject order error: $e");
    }
  }
}


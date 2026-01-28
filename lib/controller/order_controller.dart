import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  RxBool isActive = false.obs;

  //for updating toggle
  Future<void> updateIsActive(bool value) async {
    try {
      await _firestore
          .collection('moms_kitchens')
          .doc(auth.currentUser!.uid)
          .update({"isActive": value});
      isActive.value = value;
    } catch (e) {
      log("Update isActive error: $e");
    }
  }

  //for accepting order
  Future<void> aceptOrder(Map orderData) async {
    if (!isActive.value) {
      Get.snackbar(
        "Kitchen Offline",
        "Go online to accept orders",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final String docId = orderData['order_id'];

      await _firestore.collection('orders').doc(docId).update({
        "orderStatus": "accepted",
        "updatedAt": FieldValue.serverTimestamp(), //use datetime.now
      });
    } catch (e) {
      log("Accept order error: $e");
    }
  }

  //for rejecting order
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

  void toggleWithConfirmation(bool value) {
    if (!value) {
      // going offline
      Get.defaultDialog(
        title: "Go Offline?",
        middleText: "You won’t receive new orders while offline. Are you sure?",
        textConfirm: "Yes",
        textCancel: "Cancel",
        confirmTextColor: Colors.white,
        buttonColor: Colors.red,

        onConfirm: () {
          updateIsActive(false);
          Get.back();
        },
        onCancel: () {
          // do nothing → listener keeps state true
        },
      );
    } else {
      // going online
      updateIsActive(true);
    }
  }

  //for updating order status
  Future<void> updateOrderStatus({
    required String docId,
    required String status,
  }) async {
    try {
      await _firestore.collection('orders').doc(docId).update({
        "orderStatus": status,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log("Update order status error: $e");
    }
  }

  //to confirm reject order
  void confirmReject(String docId) {
    Get.defaultDialog(
      title: "Reject Order?",
      middleText: "Are you sure you want to reject this order?",
      textConfirm: "Yes, Reject",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        updateOrderStatus(docId: docId, status: "rejected");
        Get.back();
      },
    );
  }
}

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Represents a single subscription meal that is upcoming for THIS kitchen.
class UpcomingMeal {
  final String subscriptionId;
  final String userId;
  final String userName;
  final String kitchenId;
  final String kitchenName;
  final String mealTime; // "Breakfast" / "Lunch" / "Dinner"
  final List<String> foodDetails;
  final List<String> dishIds;
  final String date; // "2026-05-14"
  final String day; // "Thursday"
  final String time; // "1:30 PM"
  final String deliveryAddress;
  final String thaliType;
  final DateTime scheduledDateTime; // parsed full DateTime (date + time from config)
  final DateTime visibleFrom; // scheduledDateTime - 1 hr

  const UpcomingMeal({
    required this.subscriptionId,
    required this.userId,
    required this.userName,
    required this.kitchenId,
    required this.kitchenName,
    required this.mealTime,
    required this.foodDetails,
    required this.dishIds,
    required this.date,
    required this.day,
    required this.time,
    required this.deliveryAddress,
    required this.thaliType,
    required this.scheduledDateTime,
    required this.visibleFrom,
  });
}

class UpcomingPreparationController extends GetxController {
  // ── Public reactive state ──────────────────────────────────────────────────
  final RxList<UpcomingMeal> upcomingMeals = <UpcomingMeal>[].obs;
  final RxBool isLoading = true.obs;

  // ── Internal ───────────────────────────────────────────────────────────────
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Timer? _ticker;

  @override
  void onInit() {
    super.onInit();
    _loadAndFilter();
    // Re-evaluate visibility every second so the countdown shows live seconds
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _filter());
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }

  // ── Public ─────────────────────────────────────────────────────────────────

  /// Force a fresh reload from Firestore (e.g. on pull-to-refresh).
  Future<void> reload() async {
    isLoading.value = true;
    await _loadAndFilter();
  }

  // ── Private ────────────────────────────────────────────────────────────────

  /// All meals across all dates that belong to this kitchen (from active subscriptions).
  final List<UpcomingMeal> _allMeals = [];

  Future<void> _loadAndFilter() async {
    try {
      final kitchenId = _auth.currentUser?.uid;
      if (kitchenId == null) {
        isLoading.value = false;
        return;
      }

      // Fetch all users
      final usersSnap = await _db.collection('users').get();

      final List<UpcomingMeal> collected = [];

      for (final userDoc in usersSnap.docs) {
        final userId = userDoc.id;
        final userName =
            (userDoc.data()['name'] ??
                    userDoc.data()['userName'] ??
                    userDoc.data()['displayName'] ??
                    '')
                .toString();

        // Fetch all subscriptions for this user
        final subsSnap = await _db
            .collection('users')
            .doc(userId)
            .collection('subscriptions')
            .get();

        for (final subDoc in subsSnap.docs) {
          final sub = subDoc.data();

          // Only active subscriptions
          if (sub['isActive'] != true) continue;

          final deliveryAddress = sub['delivery_address']?.toString() ?? '';
          final mealConfigs =
              sub['mealConfigurations'] as List<dynamic>? ?? [];

          for (final rawConfig in mealConfigs) {
            if (rawConfig is! Map) continue;
            final config = Map<String, dynamic>.from(rawConfig);

            // Only process entries for THIS kitchen
            if (config['kitchenId']?.toString() != kitchenId) continue;

            final dateStr = config['date']?.toString() ?? '';
            final timeStr = config['time']?.toString() ?? '';

            // Parse the real date+time from the config (not today's date)
            final scheduledDt = _parseTimeForDate(timeStr, dateStr);
            if (scheduledDt == null) continue;

            final visibleFrom =
                scheduledDt.subtract(const Duration(hours: 1));

            final foodDetails = _toStringList(config['foodDetails']);
            final dishIds = _toStringList(config['dishIds']);

            collected.add(
              UpcomingMeal(
                subscriptionId: subDoc.id,
                userId: userId,
                userName: userName,
                kitchenId: kitchenId,
                kitchenName: config['kitchenName']?.toString() ?? '',
                mealTime: config['mealTime']?.toString() ?? '',
                foodDetails: foodDetails,
                dishIds: dishIds,
                date: dateStr,
                day: config['day']?.toString() ?? '',
                time: timeStr,
                deliveryAddress: deliveryAddress,
                thaliType: config['thaliType']?.toString() ?? 'Custom',
                scheduledDateTime: scheduledDt,
                visibleFrom: visibleFrom,
              ),
            );
          }
        }
      }

      _allMeals
        ..clear()
        ..addAll(collected);

      _filter();
    } catch (e) {
      log('UpcomingPreparationController._loadAndFilter error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Shows all meals whose visibleFrom <= now (appeared and stay permanently).
  /// Sorted newest → oldest so the latest card always stacks on top.
  void _filter() {
    final now = DateTime.now();
    final visible = _allMeals
        .where((m) => !now.isBefore(m.visibleFrom))
        .toList()
      ..sort((a, b) => b.scheduledDateTime.compareTo(a.scheduledDateTime));
    upcomingMeals.assignAll(visible);
  }

  /// Parses "1:30 PM" + "2026-05-14" into a full [DateTime].
  /// Falls back to today's date if [dateStr] is empty or malformed.
  DateTime? _parseTimeForDate(String timeStr, String dateStr) {
    try {
      final parts = timeStr.trim().split(' ');
      if (parts.length != 2) return null;
      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return null;
      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);
      final String period = parts[1].toUpperCase();

      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      // Parse the date from "YYYY-MM-DD"
      final dateParts = dateStr.split('-');
      final now = DateTime.now();
      final int year =
          dateParts.length == 3 ? int.parse(dateParts[0]) : now.year;

      final int month =
          dateParts.length == 3 ? int.parse(dateParts[1]) : now.month;
      final int day =
          dateParts.length == 3 ? int.parse(dateParts[2]) : now.day;

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      log('_parseTimeForDate error for "$timeStr" / "$dateStr": $e');
      return null;
    }
  }

  /// Safely converts a Firestore dynamic list to List<String>.
  List<String> _toStringList(dynamic raw) {
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }
}

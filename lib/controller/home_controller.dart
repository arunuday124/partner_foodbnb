import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/auth_controller.dart';
import 'package:partner_foodbnb/controller/notification_controller.dart';

class HomeController extends GetxController {
  final AuthController ac = Get.put(AuthController());
  final NotificationController nc = Get.put(NotificationController());

  Rx selectedIndex = 0.obs;

  @override
  void onInit() {
    nc.requestPushPermission();
    nc.getPushToken();
    ac.getUserData();

    super.onInit();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/auth_controller.dart';
import 'package:partner_foodbnb/view/auth_screens/login.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController ac = Get.put(AuthController());
  final String googleUid = Get.arguments ?? '';
  final PageController _pageController = PageController();
  final RxInt _currentStep = 0.obs;
  final int _totalSteps = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep.value < _totalSteps - 1) {
      _currentStep.value++;
      _pageController.animateToPage(
        _currentStep.value,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep.value > 0) {
      _currentStep.value--;
      _pageController.animateToPage(
        _currentStep.value,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryRed = Colors.red.shade400;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      if (_currentStep.value > 0) {
                        _previousStep();
                      } else {
                        Get.back();
                      }
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Obx(
                        () => Text(
                          "Step ${_currentStep.value + 1} of $_totalSteps",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer for centering
                ],
              ),
            ),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Obx(
                    () => AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      height: 6,
                      width:
                          MediaQuery.of(context).size.width *
                          ((_currentStep.value + 1) / _totalSteps),
                      decoration: BoxDecoration(
                        color: primaryRed,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: primaryRed.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Obx(
                    () => _currentStep.value > 0
                        ? Expanded(
                            child: OutlinedButton(
                              onPressed: _previousStep,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(color: primaryRed),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                "Previous",
                                style: TextStyle(
                                  color: primaryRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Obx(
                    () => _currentStep.value > 0
                        ? const SizedBox(width: 16)
                        : const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: _currentStep.value < _totalSteps - 1
                            ? _nextStep
                            : () => ac.registerUser(googleUid),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: ac.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _currentStep.value < _totalSteps - 1
                                    ? "Next"
                                    : "Register Now",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: "Become a ",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: "Foodbnb ",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade400,
                ),
              ),
              const TextSpan(
                text: "Chef 👩‍🍳",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            "Basic Info",
            "Tell us about yourself and your kitchen to get started.",
          ),
          _label("Full Name"),
          textField(
            hint: "Enter your full name",
            icon: Icons.person_outline,
            controller: ac.nameController,
          ),
          const SizedBox(height: 20),
          _label("Restaurant Name"),
          textField(
            hint: "Enter restaurant's full name",
            icon: Icons.restaurant_rounded,
            controller: ac.kitchenNamecontroller,
          ),
          const SizedBox(height: 20),
          _label("Restaurant Description"),
          textField(
            hint: "Describe your kitchen",
            icon: Icons.description_outlined,
            controller: ac.regKitchenDesController,
          ),
          const SizedBox(height: 20),
          _label("Restaurant Address"),
          textField(
            hint: "Enter full Address",
            icon: Icons.location_on_outlined,
            controller: ac.regKitchenAddress,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            "Kitchen Details",
            "What kind of delicious meals will you be serving?",
          ),
          _label("Food Preference"),
          DropdownButtonFormField<String>(
            value: ac.selectedPreference,
            hint: const Text("Select preference"),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              fillColor: Colors.grey.shade50,
              filled: true,
              prefixIcon: const Icon(Icons.favorite_border, color: Colors.grey),
            ),
            items: const [
              DropdownMenuItem(value: "Non-veg", child: Text("Non-Veg")),
              DropdownMenuItem(value: "Veg", child: Text("Veg")),
              DropdownMenuItem(value: "Pure-veg", child: Text("Pure-veg")),
            ],
            onChanged: (value) {
              ac.selectedPreference = value;
            },
          ),
          const SizedBox(height: 20),
          _label("Set Cuisine"),
          textField(
            hint: "Enter Your Cuisine (e.g. Indian, Chinese)",
            icon: Icons.room_service_outlined,
            controller: ac.regCuisineController,
          ),
          const SizedBox(height: 20),
          _label("Specialities"),
          Row(
            children: [
              Expanded(
                child: textField(
                  hint: "Add a speciality",
                  icon: Icons.stars_outlined,
                  controller: ac.regSpecialityController,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  if (ac.regSpecialityController.text.trim().isNotEmpty) {
                    ac.specialitiesList.add(
                      ac.regSpecialityController.text.trim(),
                    );
                    ac.regSpecialityController.clear();
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ac.specialitiesList.map((speciality) {
                return Chip(
                  label: Text(speciality),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => ac.specialitiesList.remove(speciality),
                  backgroundColor: Colors.red.shade50,
                  side: BorderSide(color: Colors.red.shade100),
                  labelStyle: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 13,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          _label("Shop Image"),
          GestureDetector(
            onTap: () => _showImageSourceDialog(),
            child: Obx(
              () => Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ac.selectedShopImagePath.value.isEmpty
                        ? Colors.grey.shade200
                        : Colors.red.shade200,
                    width: 1.5,
                    style: ac.selectedShopImagePath.value.isEmpty
                        ? BorderStyle.solid
                        : BorderStyle.solid,
                  ),
                ),
                child: ac.selectedShopImagePath.value.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Upload Shop Image",
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(ac.selectedShopImagePath.value),
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 16,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  onPressed: () =>
                                      ac.selectedShopImagePath.value = '',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Image Source",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _imageSourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: "Camera",
                  onTap: () {
                    Get.back();
                    ac.pickShopImage(ImageSource.camera);
                  },
                ),
                _imageSourceOption(
                  icon: Icons.photo_library_outlined,
                  label: "Gallery",
                  onTap: () {
                    Get.back();
                    ac.pickShopImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _imageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.red.shade400, size: 30),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            "Identity & Time",
            "Verify your identity and set your kitchen's availability.",
          ),
          _label("Email Address"),
          textField(
            hint: "Enter email",
            icon: Icons.email_outlined,
            controller: ac.regEmailController,
          ),
          const SizedBox(height: 20),
          _label("Phone Number"),
          textField(
            hint: "Enter your Phone Number",
            icon: Icons.phone_outlined,
            controller: ac.regPhoneController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          const SizedBox(height: 20),
          _label("Pan Number"),
          textField(
            hint: "Enter 10-digit PAN number",
            icon: Icons.badge_outlined,
            controller: ac.regPanNumberController,
          ),
          const SizedBox(height: 20),
          _label("Open & Close Time"),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _timePickerTile(
                    "Open Time",
                    ac.openTime.value,
                    Icons.access_time,
                    () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: ac.openTime.value ?? TimeOfDay.now(),
                      );
                      if (picked != null) ac.openTime.value = picked;
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => _timePickerTile(
                    "Close Time",
                    ac.closeTime.value,
                    Icons.access_time_filled,
                    () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: ac.closeTime.value ?? TimeOfDay.now(),
                      );
                      if (picked != null) ac.closeTime.value = picked;
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    final Color primaryRed = Colors.red.shade400;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            "Security",
            "Finalize your account by setting up a secure password.",
          ),
          _label("Create Password"),
          Obx(
            () => textField(
              hint: "Create password",
              icon: Icons.lock_outline,
              isPassword: true,
              controller: ac.regPasswordController,
              isVisible: ac.isPasswordVisible.value,
              onToggleVisibility: () =>
                  ac.isPasswordVisible.value = !ac.isPasswordVisible.value,
            ),
          ),
          const SizedBox(height: 20),
          _label("Confirm Password"),
          textField(
            hint: "Re-enter password",
            icon: Icons.lock_reset_outlined,
            isPassword: true,
            controller: ac.regConfirmPasswordController,
          ),
          const SizedBox(height: 32),
          Center(
            child: TextButton(
              onPressed: () => Get.off(() => Login()),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Already a partner? ",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextSpan(
                      text: "Log In",
                      style: TextStyle(
                        color: primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _timePickerTile(
    String hint,
    TimeOfDay? time,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: time != null ? Colors.red.shade200 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                time != null ? ac.timeToString(time) : hint,
                style: TextStyle(
                  fontSize: 14,
                  color: time != null ? Colors.black : Colors.grey.shade500,
                  fontWeight: time != null
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade400,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontSize: 14,
        ),
      ),
    );
  }
}

Widget textField({
  required String hint,
  required IconData icon,
  required TextEditingController controller,
  bool isPassword = false,
  VoidCallback? onToggleVisibility,
  bool? isVisible,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
}) {
  return TextField(
    controller: controller,
    obscureText: isPassword && !(isVisible ?? false),
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    style: const TextStyle(fontSize: 15),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey, size: 22),
      suffixIcon: (isPassword && onToggleVisibility != null)
          ? IconButton(
              icon: Icon(
                (isVisible ?? false) ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: onToggleVisibility,
            )
          : null,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
    ),
  );
}

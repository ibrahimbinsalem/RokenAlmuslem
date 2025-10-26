import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rokenalmuslem/controller/auth/login_controller.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/view/wedgit/auth/custom_auth_button.dart';
import 'package:rokenalmuslem/view/wedgit/auth/custom_text_field.dart';
import 'package:rokenalmuslem/view/wedgit/auth/social_login_button.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام Get.put() لتهيئة الكنترولر
    final LoginControllerImp controller = Get.put(LoginControllerImp());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const Icon(Icons.mosque_rounded, size: 80, color: Colors.teal)
                      .animate()
                      .fade(duration: 500.ms)
                      .scale(delay: 200.ms),
                  const SizedBox(height: 16),
                  Text(
                    "مرحباً بعودتك",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5),
                  const SizedBox(height: 8),
                  Text(
                    "سجل دخولك للمتابعة في ركن المسلم",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5),
                  const SizedBox(height: 40),

                  // Email Field
                  CustomAuthTextField(
                    controller: controller.email,
                    hintText: "البريد الإلكتروني",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال البريد الإلكتروني';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'بريد إلكتروني غير صالح';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.5),
                  const SizedBox(height: 20),

                  // Password Field
                  CustomAuthTextField(
                    controller: controller.password,
                    hintText: "كلمة المرور",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال كلمة المرور';
                      }
                      if (value.length < 6) {
                        return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.5),
                  const SizedBox(height: 16),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Navigate to Forgot Password screen
                      },
                      child: Text(
                        "هل نسيت كلمة المرور؟",
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms),
                  const SizedBox(height: 24),

                  // Login Button
                  Obx(
                    () => controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : CustomAuthButton(
                            text: "تسجيل الدخول",
                            onPressed: () {
                              controller.login();
                            },
                          ).animate().fadeIn(delay: 800.ms).shake(),
                  ),
                  const SizedBox(height: 32),

                  // Social Login
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text("أو سجل الدخول عبر",
                            style: theme.textTheme.bodyMedium),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ).animate().fadeIn(delay: 900.ms),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialLoginButton(
                        iconPath: 'assets/images/book.png', // تأكد من وجود الصورة
                        onTap: () {
                          // TODO: Implement Google Sign-In
                        },
                      ),
                      const SizedBox(width: 24),
                      SocialLoginButton(
                        iconPath: 'assets/images/book.png', // تأكد من وجود الصورة
                        onTap: () {
                          // TODO: Implement Apple Sign-In
                        },
                      ),
                    ],
                  ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.5),
                  const SizedBox(height: 32),

                  // Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("ليس لديك حساب؟", style: theme.textTheme.bodyMedium),
                      TextButton(
                        onPressed: () {
                          controller.goToSignUp();
                        },
                        child: Text(
                          "أنشئ حساباً",
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 1100.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

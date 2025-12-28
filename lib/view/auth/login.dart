import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rokenalmuslem/controller/auth/login_controller.dart';
import 'package:rokenalmuslem/view/wedgit/auth/custom_auth_button.dart';
import 'package:rokenalmuslem/view/wedgit/auth/custom_text_field.dart';
import 'package:rokenalmuslem/view/wedgit/auth/social_login_button.dart';
import 'package:rokenalmuslem/view/wedgit/layout/app_background.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام Get.put() لتهيئة الكنترولر
    final LoginControllerImp controller = Get.put(LoginControllerImp());
    final theme = Theme.of(context);

    return Scaffold(
      body: AppBackground(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.7),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary
                                  .withOpacity(0.12),
                            ),
                            child: Icon(
                              Icons.mosque_rounded,
                              size: 36,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        )
                            .animate()
                            .fade(duration: 500.ms)
                            .scale(delay: 200.ms),
                        const SizedBox(height: 16),
                        Text(
                          "مرحباً بعودتك",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.4),
                        const SizedBox(height: 8),
                        Text(
                          "سجل دخولك للمتابعة في ركن المسلم",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.7),
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.4),
                        const SizedBox(height: 32),

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
                        ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.4),
                        const SizedBox(height: 18),

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
                        ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.4),
                        const SizedBox(height: 10),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Navigate to Forgot Password screen
                            },
                            child: Text(
                              "هل نسيت كلمة المرور؟",
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 700.ms),
                        const SizedBox(height: 20),

                        // Login Button
                        GetX<LoginControllerImp>(
                          builder: (controller) {
                            if (controller.isLoading.value) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return CustomAuthButton(
                                  text: "تسجيل الدخول",
                                  onPressed: () {
                                    controller.login();
                                  },
                                )
                                .animate()
                                .fadeIn(delay: 800.ms)
                                .slideY(begin: 0.2);
                          },
                        ),
                        const SizedBox(height: 28),

                        // Social Login
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                "أو سجل الدخول عبر",
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ).animate().fadeIn(delay: 900.ms),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialLoginButton(
                              iconPath:
                                  'assets/images/book.png', // تأكد من وجود الصورة
                              onTap: () {
                                // TODO: Implement Google Sign-In
                              },
                            ),
                            const SizedBox(width: 18),
                            SocialLoginButton(
                              iconPath:
                                  'assets/images/book.png', // تأكد من وجود الصورة
                              onTap: () {
                                // TODO: Implement Apple Sign-In
                              },
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(delay: 1000.ms)
                            .slideY(begin: 0.4),
                        const SizedBox(height: 24),

                        // Sign Up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "ليس لديك حساب؟",
                              style: theme.textTheme.bodyMedium,
                            ),
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
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

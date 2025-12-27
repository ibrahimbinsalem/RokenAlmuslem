import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rokenalmuslem/controller/auth/signup_controller.dart';
import 'package:rokenalmuslem/view/wedgit/auth/custom_auth_button.dart';
import 'package:rokenalmuslem/view/wedgit/auth/custom_text_field.dart';
import 'package:rokenalmuslem/view/wedgit/layout/app_background.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SignUpControllerImp controller = Get.put(SignUpControllerImp());
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
                        Text(
                          "أهلاً بك في ركن المسلم",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.4),
                        const SizedBox(height: 8),
                        Text(
                          "أنشئ حسابك لتنضم إلى مجتمعنا",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.7),
                          ),
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.4),
                        const SizedBox(height: 32),

                        // Username Field
                        CustomAuthTextField(
                          controller: controller.username,
                          hintText: "اسم المستخدم",
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم المستخدم';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.4),
                        const SizedBox(height: 18),

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
                        ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.4),
                        const SizedBox(height: 18),

                        const SizedBox(height: 6),

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
                        ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.4),
                        const SizedBox(height: 24),

                        // SignUp Button
                        Obx(
                          () => controller.isLoading.value
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : CustomAuthButton(
                                    text: "إنشاء الحساب",
                                    onPressed: () {
                                      controller.signup();
                                    },
                                  )
                                  .animate()
                                  .fadeIn(delay: 800.ms)
                                  .slideY(begin: 0.2),
                        ),
                        const SizedBox(height: 18),

                        // Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "لديك حساب بالفعل؟",
                              style: theme.textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () {
                                controller.goToLogin();
                              },
                              child: Text(
                                "سجل الدخول",
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 900.ms),
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

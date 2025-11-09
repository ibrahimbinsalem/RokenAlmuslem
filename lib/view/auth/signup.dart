import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rokenalmuslem/controller/auth/signup_controller.dart';
import 'package:rokenalmuslem/view/wedgit/auth/custom_auth_button.dart';
import 'package:rokenalmuslem/view/wedgit/auth/custom_text_field.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SignUpControllerImp controller = Get.put(SignUpControllerImp());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('إنشاء حساب جديد', style: theme.textTheme.headlineSmall),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5),
                const SizedBox(height: 8),
                Text(
                  "أنشئ حسابك لتنضم إلى مجتمعنا",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5),
                const SizedBox(height: 40),

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
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.5),
                const SizedBox(height: 20),

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
                ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.5),
                const SizedBox(height: 20),

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
                ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.5),
                const SizedBox(height: 32),

                // SignUp Button
                Obx(
                  () =>
                      controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : CustomAuthButton(
                            text: "إنشاء الحساب",
                            onPressed: () {
                              controller.signup();
                            },
                          ).animate().fadeIn(delay: 800.ms).shake(),
                ),
                const SizedBox(height: 24),

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
        ),
      ),
    );
  }
}

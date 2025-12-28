import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rokenalmuslem/view/wedgit/layout/modern_scaffold.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);
    return ModernScaffold(
      title: 'حول التطبيق والمطورين',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeaderSection(currentTheme),
            const SizedBox(height: 24),

            // قسم المطور الرئيسي
            _buildSectionTitle('الفريق التقني', currentTheme),
            _buildMainDeveloperCard(currentTheme),

            // قسم فريق البحث والمراجعة
            _buildSectionTitle('البحث والمراجعة تمت من قبل', currentTheme),
            _buildTeamMemberCard(
              context,
              name: ' الدكتور عبدالله بن محمد بارباع',
              role: 'الدكتوراة بأمتياز مع مرتبة الشرف الأولى',
              description: 'من الجامعة الإسلامية بالمدينة المنورة',
              icon: Icons.menu_book_rounded,
              theme: currentTheme,
              avatarColor: Colors.blue,
            ),
            // _buildTeamMemberCard(
            //   context,
            //   name: '',
            //   role: '',
            //   description: '',
            //   icon: Icons.design_services_rounded,
            //   theme: currentTheme,
            //   avatarColor: Colors.purple,
            // ),
            // _buildTeamMemberCard(
            //   context,
            //   name: 'فهد محمد الحيقي',
            //   role: 'ناشر للتطبيق',
            //   description: 'متخصص في عملية النشر للتطبيق ',
            //   icon: Icons.gavel_rounded,
            //   theme: currentTheme,
            //   avatarColor: Colors.orange,
            // ),

            // قسم الشكر والتقدير
            _buildSectionTitle('كلمة شكر', currentTheme),
            _buildThankYouCard(currentTheme),

            // معلومات التطبيق
            _buildAppInfoSection(currentTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.mosque_rounded,
            size: 60,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'روكن المسلم',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تطبيق متكامل لخدمة المسلم في حياته اليومية',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(width: 12),
          Container(
            height: 24,
            width: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainDeveloperCard(ThemeData theme) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'ابراهيم بن سلم',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        'المطور الرئيسي',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.teal.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.code_rounded,
                      color: Colors.teal,
                      size: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'مطور تطبيقات Flutter بخبرة 3 سنوات في تطوير التطبيقات الإسلامية. '
                'متخصص في إنشاء تطبيقات ذات واجهة مستخدم جذابة وسهلة الاستخدام.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.9),
                  height: 1.6,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 16),
              _buildContactInfo(theme),
              const SizedBox(height: 8),
              _buildSocialMediaLinks(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildContactItem(
          icon: Icons.email_rounded,
          text: 'ibrahimghanem707@gmail.com',
          theme: theme,
        ),
        _buildContactItem(
          icon: Icons.phone_rounded,
          text: '+967737588783',
          theme: theme,
        ),
        _buildContactItem(
          icon: Icons.location_on_rounded,
          text: 'اليمن - حضرموت - المكلاء',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String text,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(width: 8),
          Icon(icon, color: theme.colorScheme.primary, size: 20),
        ],
      ),
    );
  }

  Widget _buildSocialMediaLinks(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 12),
        _buildSocialIcon(
          FontAwesomeIcons.github,
          Colors.black.withValues(alpha: 0.9),
          theme,
        ),
        const SizedBox(width: 12),
        _buildSocialIcon(FontAwesomeIcons.linkedin, Colors.blue, theme),
        const SizedBox(width: 12),
        _buildSocialIcon(
          FontAwesomeIcons.instagram,
          const Color(0xFFE1306C),
          theme,
        ),
        const SizedBox(width: 12),
        _buildSocialIcon(
          FontAwesomeIcons.whatsapp,
          const Color(0xFF25D366),
          theme,
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color, ThemeData theme) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? theme.colorScheme.surfaceVariant
                : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(child: FaIcon(icon, color: color, size: 18)),
    );
  }

  Widget _buildTeamMemberCard(
    BuildContext context, {
    required String name,
    required String role,
    required String description,
    required IconData icon,
    required ThemeData theme,
    required Color avatarColor,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface,
              theme.colorScheme.surfaceVariant,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.9),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: avatarColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: avatarColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Icon(icon, color: avatarColor, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThankYouCard(ThemeData theme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.colorScheme.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.favorite_rounded, color: Colors.red, size: 40),
            const SizedBox(height: 16),
            Text(
              'الشكر والتقدير',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            Text(
              'نتقدم بجزيل الشكر والعرفان لكل من ساهم في إنجاز هذا العمل، '
              'ولكل من دعمنا بفكره أو وقته أو جهده. نسأل الله أن يتقبل منا '
              'ومنكم صالح الأعمال، وأن يجعل هذا التطبيق خالصاً لوجهه الكريم.'
              'مع الإشارة أنه سوف يتم تطوير التطبيق أولا بأول وأضافت بعض الميزات الأحدث والأجمل '
              'واتمنئ أن استقبل مقترحاتكم والتواصل معي في حالة وجود أي مشكلة أو أردتم إضافة أي فكرة جديدة للتطبيق',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.6,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoSection(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Divider(
          color: theme.colorScheme.onSurface.withOpacity(0.1),
          thickness: 1,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'نسخة التطبيق: 1.0.1',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '© 2025 روكن المسلم - جميع الحقوق محفوظة',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

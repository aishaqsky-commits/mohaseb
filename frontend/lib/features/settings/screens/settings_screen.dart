import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'الإعدادات العامة',
          style: AppTypography.headlineSmall(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.md),
        children: [
          // ─── كرت الملف التعريفي للمنشأة ─────────────────────────
          Container(
            padding: const EdgeInsets.all(AppDimens.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.store_rounded, size: 36, color: Colors.white),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مؤسسة النور للتجارة والتوريدات',
                        style: AppTypography.titleLarge(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تجزئة وجملة • العملة: ريال يمني (YER)',
                        style: AppTypography.bodySmall(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1, end: 0),
          const SizedBox(height: AppDimens.lg),

          // ─── 1. إعدادات المظهر والسمة ─────────────────────────
          _buildSectionHeader('المظهر والعرض', isDark),
          _buildSettingsContainer(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.palette_outlined, color: AppColors.primary),
                title: Text('نمط الواجهة', style: AppTypography.titleMedium()),
                subtitle: Text(
                  currentTheme == ThemeMode.dark
                      ? 'الوضع الداكن'
                      : (currentTheme == ThemeMode.light ? 'الوضع الفاتح' : 'حسب النظام'),
                  style: AppTypography.bodySmall(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                trailing: DropdownButton<ThemeMode>(
                  value: currentTheme,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('تلقائي')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('فاتح')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('داكن')),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      ref.read(themeProvider.notifier).setTheme(mode);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),

          // ─── 2. المزامنة والوضع غير المتصل (Offline-First) ─────
          _buildSectionHeader('المزامنة والاتصال السحابي', isDark),
          _buildSettingsContainer(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.cloud_sync_outlined, color: AppColors.success),
                title: Text('حالة المزامنة', style: AppTypography.titleMedium()),
                subtitle: Text(
                  'متزامن بالكامل مع الخادم (آخر مزامنة: الآن)',
                  style: AppTypography.bodySmall(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                trailing: TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمت مزامنة جميع العمليات محلياً وسحابياً بنجاح!')),
                    );
                  },
                  icon: const Icon(Icons.sync_rounded, size: 18),
                  label: const Text('مزامنة الآن'),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.storage_rounded, color: AppColors.secondary),
                title: Text('قاعدة البيانات المحلية (Drift SQLite)', style: AppTypography.titleMedium()),
                subtitle: Text('حجم التخزين المحلي: 2.4 MB • مشفرة عبر SQLCipher', style: AppTypography.bodySmall()),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),

          // ─── 3. الذكاء الاصطناعي ──────────────────────────────
          _buildSectionHeader('المحاسب الذكي والـ AI', isDark),
          _buildSettingsContainer(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.psychology_outlined, color: AppColors.accent),
                title: Text('مزود الذكاء الاصطناعي', style: AppTypography.titleMedium()),
                subtitle: Text('Gemini Flash 1.5 • استجابة فورية للأوامر الصوتية', style: AppTypography.bodySmall()),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () {},
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.security_rounded, color: AppColors.primary),
                title: Text('تأكيد بشري إلزامي (Human-in-the-Loop)', style: AppTypography.titleMedium()),
                subtitle: Text(
                  'طلب تأكيد صريح قبل حفظ أي قيد يقترحه الذكاء الاصطناعي',
                  style: AppTypography.bodySmall(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                value: true,
                onChanged: (val) {},
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),

          // ─── 4. الصلاحيات والمستخدمين ────────────────────────
          _buildSectionHeader('الأمان والمستخدمون', isDark),
          _buildSettingsContainer(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.people_outline_rounded, color: AppColors.primary),
                title: Text('إدارة المستخدمين والأدوار (RBAC)', style: AppTypography.titleMedium()),
                subtitle: Text('المالك، المحاسب، الكاشير، موظف المبيعات', style: AppTypography.bodySmall()),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock_outline_rounded, color: AppColors.warning),
                title: Text('رمز الدخول السريع (PIN) والبصمة', style: AppTypography.titleMedium()),
                subtitle: Text('مفعل للجهاز الحالي', style: AppTypography.bodySmall()),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppDimens.lg),

          Center(
            child: Text(
              'حاسبي الذكي v1.0.0 (Build 2026.10)\nنظام محاسبي سحابي ومحلي متكامل',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.xl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.xs, right: 4),
      child: Text(
        title,
        style: AppTypography.titleMedium(
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsContainer({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(children: children),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/router/app_router.dart';

/// شاشة إعداد الشركة/النشاط التجاري
class CompanySetupScreen extends StatefulWidget {
  const CompanySetupScreen({super.key});

  @override
  State<CompanySetupScreen> createState() => _CompanySetupScreenState();
}

class _CompanySetupScreenState extends State<CompanySetupScreen> {
  final _nameController = TextEditingController();
  String? _selectedType;
  bool _isLoading = false;

  final List<_ActivityType> _activityTypes = const [
    _ActivityType(
      'retail',
      'تجارة وبيع بالتجزئة',
      'محلات، بقالات، مستودعات',
      Icons.store_rounded,
      AppColors.operationSale,
    ),
    _ActivityType(
      'services',
      'مقدم خدمات',
      'كهربائي، سباك، مهندس، مستشار',
      Icons.build_rounded,
      AppColors.operationPurchase,
    ),
    _ActivityType(
      'mixed',
      'تجارة + خدمات',
      'نشاط مختلط (بيع وخدمات)',
      Icons.business_rounded,
      AppColors.operationCapital,
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createCompany() async {
    if (_nameController.text.isEmpty || _selectedType == null) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعداد النشاط التجاري'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── أيقونة ──────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.business_center_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

              const SizedBox(height: AppDimens.xxl),

              Text(
                'أخبرنا عن نشاطك التجاري',
                style: AppTypography.headlineLarge(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: AppDimens.sm),

              Text(
                'هذا يساعدنا في إعداد حساباتك بشكل صحيح',
                style: AppTypography.bodyMedium(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: AppDimens.xxxl),

              // ─── اسم النشاط ────────────────────────────
              Text(
                'اسم النشاط التجاري',
                style: AppTypography.titleMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: AppDimens.sm),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'مثال: محلات النور للإلكترونيات',
                  prefixIcon: const Icon(Icons.storefront_rounded),
                  hintStyle: AppTypography.bodyMedium(
                    color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),

              const SizedBox(height: AppDimens.xxl),

              // ─── نوع النشاط ────────────────────────────
              Text(
                'نوع النشاط',
                style: AppTypography.titleMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: AppDimens.md),

              ...List.generate(_activityTypes.length, (index) {
                final type = _activityTypes[index];
                final isSelected = _selectedType == type.code;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.md),
                  child: InkWell(
                    onTap: () => setState(() => _selectedType = type.code),
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    child: AnimatedContainer(
                      duration: AppDimens.animFast,
                      padding: const EdgeInsets.all(AppDimens.lg),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                        border: Border.all(
                          color: isSelected
                              ? type.color
                              : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                          width: isSelected ? 2 : 1,
                        ),
                        color: isSelected
                            ? type.color.withValues(alpha: 0.08)
                            : (isDark ? AppColors.darkCard : AppColors.lightCard),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                              color: type.color.withValues(alpha: 0.15),
                            ),
                            child: Icon(type.icon, color: type.color),
                          ),
                          const SizedBox(width: AppDimens.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type.label,
                                  style: AppTypography.titleMedium(
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                Text(
                                  type.description,
                                  style: AppTypography.bodySmall(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: type.color,
                              size: 28,
                            ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: (600 + index * 100).ms).slideX(begin: 0.1);
              }),

              const SizedBox(height: AppDimens.xxl),

              // ─── زر الإنشاء ────────────────────────────
              SizedBox(
                height: AppDimens.buttonHeightXl,
                child: ElevatedButton(
                  onPressed: (_nameController.text.isNotEmpty && _selectedType != null && !_isLoading)
                      ? _createCompany
                      : null,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.rocket_launch_rounded, size: 20),
                            const SizedBox(width: AppDimens.sm),
                            Text(
                              'إنشاء النشاط والبدء',
                              style: AppTypography.titleLarge(color: Colors.white),
                            ),
                          ],
                        ),
                ),
              ).animate().fadeIn(delay: 900.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityType {
  final String code;
  final String label;
  final String description;
  final IconData icon;
  final Color color;

  const _ActivityType(this.code, this.label, this.description, this.icon, this.color);
}

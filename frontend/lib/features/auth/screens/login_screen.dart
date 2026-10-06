import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/router/app_router.dart';

/// شاشة تسجيل الدخول - رقم الهاتف
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedCountry = '+967';
  bool _isLoading = false;

  final List<_CountryCode> _countries = const [
    _CountryCode('+967', '🇾🇪', 'اليمن'),
    _CountryCode('+966', '🇸🇦', 'السعودية'),
    _CountryCode('+20', '🇪🇬', 'مصر'),
    _CountryCode('+971', '🇦🇪', 'الإمارات'),
    _CountryCode('+968', '🇴🇲', 'عُمان'),
    _CountryCode('+974', '🇶🇦', 'قطر'),
    _CountryCode('+973', '🇧🇭', 'البحرين'),
    _CountryCode('+965', '🇰🇼', 'الكويت'),
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // محاكاة إرسال OTP
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    final phone = '$_selectedCountry${_phoneController.text}';
    context.push(AppRoutes.otp, extra: phone);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimens.huge),

                // ─── الشعار ──────────────────────────────
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(),

                const SizedBox(height: AppDimens.xxl),

                // ─── العنوان ──────────────────────────────
                Text(
                  'مرحباً بك',
                  style: AppTypography.displayMedium(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

                const SizedBox(height: AppDimens.sm),

                Text(
                  'أدخل رقم هاتفك للبدء',
                  style: AppTypography.bodyLarge(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),

                const SizedBox(height: AppDimens.huge),

                // ─── اختيار الدولة + رقم الهاتف ──────────
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    border: Border.all(
                      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    ),
                    color: isDark ? AppColors.darkCard : AppColors.grey50,
                  ),
                  child: Row(
                    children: [
                      // قائمة الدول
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                            ),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountry,
                            isDense: true,
                            items: _countries.map((c) {
                              return DropdownMenuItem(
                                value: c.code,
                                child: Text(
                                  '${c.flag} ${c.code}',
                                  style: AppTypography.bodyMedium(),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedCountry = value!);
                            },
                          ),
                        ),
                      ),

                      // حقل رقم الهاتف
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(9),
                          ],
                          decoration: InputDecoration(
                            hintText: 'رقم الهاتف',
                            hintStyle: AppTypography.bodyMedium(
                              color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.lg,
                              vertical: AppDimens.lg,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال رقم الهاتف';
                            }
                            if (value.length < 7) {
                              return 'رقم الهاتف غير صحيح';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                const SizedBox(height: AppDimens.xxl),

                // ─── زر إرسال الرمز ──────────────────────
                SizedBox(
                  height: AppDimens.buttonHeightXl,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp,
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
                              const Icon(Icons.sms_rounded, size: 20),
                              const SizedBox(width: AppDimens.sm),
                              Text(
                                'إرسال رمز التحقق',
                                style: AppTypography.titleLarge(color: Colors.white),
                              ),
                            ],
                          ),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

                const SizedBox(height: AppDimens.xxxl),

                // ─── شروط الاستخدام ──────────────────────
                Text(
                  'بالمتابعة، أنت توافق على شروط الاستخدام وسياسة الخصوصية',
                  style: AppTypography.bodySmall(
                    color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountryCode {
  final String code;
  final String flag;
  final String name;

  const _CountryCode(this.code, this.flag, this.name);
}

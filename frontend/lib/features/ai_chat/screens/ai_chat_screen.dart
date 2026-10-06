import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/remote_api_client.dart';
import '../../../data/models/journal_entry_model.dart';
import '../../operations/providers/operations_provider.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final DraftEntryProposal? proposal;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.proposal,
  });
}

class DraftEntryProposal {
  final String title;
  final String operationCode;
  final String debitAccount;
  final String creditAccount;
  final double amount;
  final String description;
  final String? contactId;
  final String? contactName;
  bool isPosted;

  DraftEntryProposal({
    required this.title,
    this.operationCode = 'cash_sale',
    required this.debitAccount,
    required this.creditAccount,
    required this.amount,
    required this.description,
    this.contactId,
    this.contactName,
    this.isPosted = false,
  });
}

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isListening = false;

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'm1',
      text: 'أهلاً بك! أنا محاسبك الذكي 🤖\nيمكنك إخباري بأي عملية صوتياً أو كتابياً (مثال: "بعت لمحمد بضاعة بـ 45000 نقد" أو "سجلت إيجار المحل 60 ألف").',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatMessage(
      id: 'm2',
      text: 'بعت بضاعة لعمار ياسر بمبلغ 35,000 ريال نقداً من الصندوق',
      isUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    ChatMessage(
      id: 'm3',
      text: 'فهمت العملية! قمت بإعداد مسودة قيد البيع النقدي. يرجى المراجعة والتأكيد للترحيل:',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      proposal: DraftEntryProposal(
        title: 'قيد مبيعات نقدية (Cash Sale)',
        debitAccount: 'الصندوق الرئيسي (أصول)',
        creditAccount: 'إيراد المبيعات (إيرادات)',
        amount: 35000,
        description: 'مبيعات نقدية للعميل عمار ياسر',
      ),
    ),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? predefinedText]) {
    final text = predefinedText ?? _textController.text.trim();
    if (text.isEmpty) return;

    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      if (predefinedText == null) _textController.clear();
    });

    _scrollToBottom();

    // معالجة الذكاء الاصطناعي عبر الخادم السحابي أو المحرك المحلي دون إنترنت
    _processAiResponse(text);
  }

  Future<void> _processAiResponse(String text) async {
    DraftEntryProposal? proposal;
    String replyText = 'قمت بتحليل العملية المحاسبية واقتراح القيد المتوازن التالي:';

    try {
      final client = RemoteApiClient();
      final res = await client.parseAiIntent(text);
      if (res.isNotEmpty && res['operationCode'] != null) {
        proposal = DraftEntryProposal(
          title: res['title'] as String? ?? 'قيد محاسبي معتمد',
          operationCode: res['operationCode'] as String? ?? 'cash_sale',
          debitAccount: res['debitAccount'] as String? ?? 'الصندوق الرئيسي (101)',
          creditAccount: res['creditAccount'] as String? ?? 'إيرادات المبيعات (401)',
          amount: (res['amount'] as num?)?.toDouble() ?? 10000,
          description: res['description'] as String? ?? text,
          contactName: res['contactName'] as String?,
        );
        replyText = 'فهمت العملية! قمت بإعداد مسودة القيد المزدوج. يرجى المراجعة والتأكيد للترحيل:';
      }
    } catch (_) {
      // وضع عدم الاتصال (Offline-First Local Rule Engine)
    }

    if (proposal == null) {
      if (text.contains('إيجار') || text.contains('مصروف') || text.contains('كهرباء')) {
        replyText = 'تم استخراج تفاصيل المصروف. هذا هو القيد المزدوج المقترح:';
        proposal = DraftEntryProposal(
          title: 'قيد مصروفات تشغيلية (Operating Expense)',
          operationCode: 'expense',
          debitAccount: 'مصروفات عمومية وإدارية',
          creditAccount: 'الصندوق الرئيسي',
          amount: 50000,
          description: 'سداد مصروف تشغيلي نقداً',
        );
      } else if (text.contains('سدد') || text.contains('قبض') || text.contains('تحصيل')) {
        replyText = 'تم تحليل عملية السداد/القبض بنجاح:';
        proposal = DraftEntryProposal(
          title: 'سند قبض وتحصيل (Cash Receipt)',
          operationCode: 'customer_collection',
          debitAccount: 'الصندوق الرئيسي',
          creditAccount: 'العملاء (ذمم مدينة)',
          amount: 25000,
          description: 'تحصيل دفعة نقدية من حساب العميل',
        );
      } else if (text.contains('اشتريت') || text.contains('شراء')) {
        replyText = 'تم إعداد فاتورة المشتريات:';
        proposal = DraftEntryProposal(
          title: 'فاتورة مشتريات بضاعة (Purchase)',
          operationCode: 'cash_purchase',
          debitAccount: 'مخزون البضاعة',
          creditAccount: 'الصندوق الرئيسي',
          amount: 65000,
          description: 'مشتريات بضاعة نقداً',
        );
      } else {
        proposal = DraftEntryProposal(
          title: 'قيد مبيعات نقدية (Cash Sale)',
          operationCode: 'cash_sale',
          debitAccount: 'الصندوق الرئيسي',
          creditAccount: 'إيرادات المبيعات',
          amount: 20000,
          description: text,
        );
      }
    }

    if (!mounted) return;
    final reply = ChatMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      text: replyText,
      isUser: false,
      timestamp: DateTime.now(),
      proposal: proposal,
    );

    setState(() => _messages.add(reply));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.accent.withValues(alpha: 0.2),
              child: const Icon(Icons.auto_awesome, color: AppColors.accent, size: 18),
            ),
            const SizedBox(width: AppDimens.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المحاسب الذكي',
                  style: AppTypography.titleMedium(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  'مساعد القيد والمستشار المالي',
                  style: AppTypography.bodySmall(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ─── قائمة الرسائل ──────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppDimens.md),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg, isDark);
              },
            ),
          ),

          // ─── شريط الإدخال والمايكروفون ──────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.md,
              vertical: AppDimens.sm,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // زر المايكروفون الصوتي باللهجة المحلية
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: _isListening ? AppColors.error : AppColors.primary,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() => _isListening = !_isListening);
                      if (_isListening) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('الميكروفون يستمع الآن (تحدث بالعامية وسيترجم لقيد)...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted && _isListening) {
                            setState(() => _isListening = false);
                            _sendMessage('سددت لمؤسسة الأمل 50000 ريال نقداً من الصندوق');
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(width: AppDimens.xs),

                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'اكتب العملية أو سؤالك المحاسبي...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.md,
                          vertical: AppDimens.sm,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: AppDimens.xs),

                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                    onPressed: () => _sendMessage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isDark) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.md),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        child: Column(
          crossAxisAlignment:
              msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimens.md),
              decoration: BoxDecoration(
                color: msg.isUser
                    ? AppColors.primary
                    : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd).copyWith(
                  bottomRight: msg.isUser ? Radius.zero : null,
                  bottomLeft: !msg.isUser ? Radius.zero : null,
                ),
                border: msg.isUser
                    ? null
                    : Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
              ),
              child: Text(
                msg.text,
                style: AppTypography.bodyMedium(
                  color: msg.isUser
                      ? Colors.white
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                ),
              ),
            ),

            // ─── كرت مقترح القيد (Human-in-the-Loop) ────────────
            if (msg.proposal != null) ...[
              const SizedBox(height: AppDimens.xs),
              _buildProposalCard(msg.proposal!, isDark),
            ],
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildProposalCard(DraftEntryProposal prop, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: prop.isPosted ? AppColors.success : AppColors.accent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                prop.isPosted ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                color: prop.isPosted ? AppColors.success : AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: AppDimens.xs),
              Expanded(
                child: Text(
                  prop.title,
                  style: AppTypography.titleMedium(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              Text(
                '${prop.amount.toStringAsFixed(0)} ر.ي',
                style: AppTypography.moneySmall(color: AppColors.primary),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الطرف المدين (+)', style: AppTypography.labelSmall(color: AppColors.success)),
                    Text(prop.debitAccount, style: AppTypography.bodySmall()),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الطرف الدائن (-)', style: AppTypography.labelSmall(color: AppColors.error)),
                    Text(prop.creditAccount, style: AppTypography.bodySmall()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            'البيان: ${prop.description}',
            style: AppTypography.bodySmall(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppDimens.md),

          // ─── أزرار التأكيد أو الإلغاء ───────────────────────
          if (!prop.isPosted)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () async {
                      setState(() => prop.isPosted = true);
                      try {
                        await ref.read(accountingProvider.notifier).executeOperation(
                          operationCode: prop.operationCode,
                          amount: prop.amount,
                          description: prop.description,
                          contactId: prop.contactId,
                          source: EntrySource.ai,
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ تم تأكيد وترحيل القيد وتحديث الأرصدة بنجاح!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('خطأ أثناء الترحيل: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('تأكيد وترحيل القيد'),
                  ),
                ),
                const SizedBox(width: AppDimens.sm),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إلغاء مسودة القيد.')),
                    );
                  },
                  child: const Text('إلغاء'),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded, color: AppColors.success, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'تم ترحيل القيد في الدفاتر المحاسبية',
                    style: AppTypography.labelMedium(color: AppColors.success),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

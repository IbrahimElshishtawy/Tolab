import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/support_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../features/profile/presentation/providers/profile_providers.dart';
import '../providers/support_providers.dart';

class ItSupportChatPage extends ConsumerStatefulWidget {
  const ItSupportChatPage({super.key});

  @override
  ConsumerState<ItSupportChatPage> createState() => _ItSupportChatPageState();
}

class _ItSupportChatPageState extends ConsumerState<ItSupportChatPage> {
  final _messageController = TextEditingController();
  SupportTicketCategory _category = SupportTicketCategory.technical;
  String? _attachmentName;
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(supportTicketsProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('التحدث مع IT')),
      body: SafeArea(
        child: AdaptivePageContainer(
          child: ticketsAsync.when(
            data: (tickets) {
              final activeTicket = tickets.firstWhere(
                (ticket) =>
                    ticket.category == SupportTicketCategory.technical ||
                    ticket.category == SupportTicketCategory.quiz,
                orElse: () => tickets.isEmpty
                    ? const SupportTicket(
                        id: '',
                        ticketId: '',
                        title: '',
                        description: '',
                        category: SupportTicketCategory.technical,
                        priority: SupportTicketPriority.medium,
                        status: SupportTicketStatus.pending,
                        createdAtLabel: '',
                        updatedAtLabel: '',
                        studentName: '',
                        studentCode: '',
                      )
                    : tickets.first,
              );

              return Column(
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'قناة الدعم الفني السريعة',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'يمكنك إرسال رسالة مباشرة إلى فريق IT، وسيتم ربطها تلقائيًا بحسابك الجامعي.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            AppBadge(
                              label: profileAsync.value == null
                                  ? 'جاري تحميل بيانات الطالب'
                                  : '${profileAsync.value!.fullName} • ${profileAsync.value!.studentNumber}',
                            ),
                            if (activeTicket.ticketId.isNotEmpty)
                              AppBadge(
                                label:
                                    'التذكرة الحالية: ${activeTicket.ticketId}',
                                backgroundColor: AppColors.support.withValues(
                                  alpha: 0.12,
                                ),
                                foregroundColor: AppColors.support,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: AppCard(
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              itemCount: activeTicket.messages.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                final message = activeTicket.messages[index];
                                final bubbleColor = message.isMine
                                    ? context.appColors.primarySoft
                                    : context.appColors.surfaceAlt;
                                return Align(
                                  alignment: message.isMine
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 620,
                                    ),
                                    padding: const EdgeInsets.all(
                                      AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: bubbleColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: context.appColors.border,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: message.isMine
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message.authorName,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelLarge,
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(message.content),
                                        if (message.attachmentName != null) ...[
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            'مرفق: ${message.attachmentName}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ],
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          message.createdAtLabel,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          DropdownButtonFormField<SupportTicketCategory>(
                            initialValue: _category,
                            decoration: const InputDecoration(
                              labelText: 'نوع المشكلة',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: SupportTicketCategory.technical,
                                child: Text('مشكلة تقنية'),
                              ),
                              DropdownMenuItem(
                                value: SupportTicketCategory.quiz,
                                child: Text('مشكلة في كويز'),
                              ),
                              DropdownMenuItem(
                                value: SupportTicketCategory.subject,
                                child: Text('مشكلة في مادة'),
                              ),
                            ],
                            onChanged: _isSending
                                ? null
                                : (value) => setState(
                                    () => _category =
                                        value ??
                                        SupportTicketCategory.technical,
                                  ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            controller: _messageController,
                            label: 'الرسالة',
                            hintText: 'اكتب تفاصيل المشكلة أو سؤالك',
                            maxLines: 3,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              AppButton(
                                label: _attachmentName == null
                                    ? 'إرفاق صورة أو ملف'
                                    : _attachmentName!,
                                onPressed: _isSending ? null : _pickAttachment,
                                isExpanded: false,
                                variant: AppButtonVariant.secondary,
                                icon: Icons.attach_file_rounded,
                              ),
                              AppButton(
                                label: _isSending
                                    ? 'جارٍ الإرسال...'
                                    : 'إرسال إلى IT',
                                onPressed: _isSending
                                    ? null
                                    : () => _sendMessage(activeTicket),
                                isExpanded: false,
                                icon: Icons.send_rounded,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAttachment() async {
    final controller = TextEditingController(text: _attachmentName ?? '');
    final fileName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اسم الملف أو الصورة'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'مثال: error-shot.png'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('إرفاق'),
          ),
        ],
      ),
    );
    if (!mounted || fileName == null || fileName.isEmpty) {
      return;
    }
    setState(() => _attachmentName = fileName);
  }

  Future<void> _sendMessage(SupportTicket activeTicket) async {
    final content = _messageController.text.trim();
    if (content.isEmpty) {
      return;
    }

    setState(() => _isSending = true);

    if (activeTicket.ticketId.isEmpty) {
      await ref
          .read(supportTicketsProvider.notifier)
          .createTicket(
            SupportTicketDraft(
              category: _category,
              priority: SupportTicketPriority.high,
              title: 'طلب تواصل مع IT',
              description: content,
              attachmentName: _attachmentName,
            ),
          );
    } else {
      await ref
          .read(supportTicketsProvider.notifier)
          .sendMessage(
            ticketId: activeTicket.ticketId,
            content: content,
            attachmentName: _attachmentName,
          );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSending = false;
      _attachmentName = null;
    });
    _messageController.clear();
  }
}

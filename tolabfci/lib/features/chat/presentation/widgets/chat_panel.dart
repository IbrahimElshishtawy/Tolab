import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/community_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../subject_details/presentation/providers/chat_providers.dart';
import 'chat_input_bar.dart';
import 'chat_message_bubble.dart';

class ChatPanel extends ConsumerWidget {
  const ChatPanel({
    super.key,
    required this.subjectId,
    this.fillAvailable = true,
    this.compact = false,
  });

  final String subjectId;
  final bool fillAvailable;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatAsync = ref.watch(chatControllerProvider(subjectId));

    return chatAsync.when(
      data: (chatState) => AppCard(
        backgroundColor: context.appColors.surfaceElevated,
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.groups_2_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'الجروب / Course Group',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (chatState.messages.isNotEmpty)
                  Text(
                    '${chatState.messages.length} رسالة',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
              ],
            ),
            if (chatState.hasMore) ...[
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: AppButton(
                  label: chatState.isLoadingMore
                      ? 'جار التحميل...'
                      : 'رسائل أقدم',
                  onPressed: chatState.isLoadingMore
                      ? null
                      : () => ref
                            .read(chatControllerProvider(subjectId).notifier)
                            .loadMore(),
                  variant: AppButtonVariant.ghost,
                  isExpanded: false,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            _MessageList(
              fillAvailable: fillAvailable,
              messages: chatState.messages,
            ),
            const SizedBox(height: AppSpacing.sm),
            ChatInputBar(
              compact: compact,
              isSending: chatState.isSending,
              onSend: (content) => ref
                  .read(chatControllerProvider(subjectId).notifier)
                  .sendMessage(content),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: LoadingWidget()),
      error: (error, stackTrace) => Text(error.toString()),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.fillAvailable, required this.messages});

  final bool fillAvailable;
  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    final list = messages.isEmpty
        ? Center(
            child: Text(
              'لا توجد رسائل بعد. ابدأ النقاش من هنا.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        : ListView.separated(
            reverse: true,
            padding: EdgeInsets.zero,
            itemCount: messages.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) {
              final reversedIndex = messages.length - 1 - index;
              return ChatMessageBubble(message: messages[reversedIndex]);
            },
          );

    if (fillAvailable) {
      return Expanded(child: list);
    }

    return SizedBox(height: 340, child: list);
  }
}

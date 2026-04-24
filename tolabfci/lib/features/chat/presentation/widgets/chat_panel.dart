import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../subject_details/presentation/providers/chat_providers.dart';
import 'chat_input_bar.dart';
import 'chat_message_bubble.dart';

class ChatPanel extends ConsumerWidget {
  const ChatPanel({super.key, required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatAsync = ref.watch(chatControllerProvider(subjectId));

    return chatAsync.when(
      data: (chatState) => AppCard(
        child: Column(
          children: [
            if (chatState.hasMore)
              Align(
                alignment: Alignment.centerLeft,
                child: AppButton(
                  label: chatState.isLoadingMore
                      ? 'Loading...'
                      : 'Load earlier messages',
                  onPressed: chatState.isLoadingMore
                      ? null
                      : () => ref
                            .read(chatControllerProvider(subjectId).notifier)
                            .loadMore(),
                  variant: AppButtonVariant.ghost,
                  isExpanded: false,
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.separated(
                reverse: true,
                itemCount: chatState.messages.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final reversedIndex = chatState.messages.length - 1 - index;
                  return ChatMessageBubble(
                    message: chatState.messages[reversedIndex],
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ChatInputBar(
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

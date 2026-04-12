import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/community_models.dart';
import '../../../subjects/data/repositories/mock_subjects_repository.dart';

class ChatState {
  const ChatState({
    required this.messages,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
    this.isSending = false,
  });

  final List<ChatMessage> messages;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isSending;

  ChatState copyWith({
    List<ChatMessage>? messages,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isSending,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSending: isSending ?? this.isSending,
    );
  }
}

final chatControllerProvider =
    AsyncNotifierProviderFamily<ChatController, ChatState, String>(
  ChatController.new,
);

class ChatController extends FamilyAsyncNotifier<ChatState, String> {
  static const _pageSize = 15;
  late final String _subjectId;

  @override
  Future<ChatState> build(String arg) async {
    _subjectId = arg;
    final messages =
        await ref.watch(subjectsRepositoryProvider).fetchChatMessages(arg, pageSize: _pageSize);
    return ChatState(
      messages: messages,
      page: 0,
      hasMore: messages.length == _pageSize,
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) {
      return;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = current.page + 1;
    final olderMessages = await ref.read(subjectsRepositoryProvider).fetchChatMessages(
          _subjectId,
          page: nextPage,
          pageSize: _pageSize,
        );
    state = AsyncData(
      current.copyWith(
        messages: [...olderMessages, ...current.messages],
        page: nextPage,
        hasMore: olderMessages.length == _pageSize,
        isLoadingMore: false,
      ),
    );
  }

  Future<void> sendMessage(String content) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(isSending: true));
    await ref.read(subjectsRepositoryProvider).sendChatMessage(
          subjectId: _subjectId,
          content: content,
        );
    final refreshed =
        await ref.read(subjectsRepositoryProvider).fetchChatMessages(_subjectId, pageSize: _pageSize);
    state = AsyncData(
      ChatState(
        messages: refreshed,
        page: 0,
        hasMore: refreshed.length == _pageSize,
      ),
    );
  }
}

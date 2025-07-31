// ignore_for_file: non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:tolab/page/chat/chat/models/chat_message_model.dart';
import 'package:tolab/page/chat/chat/services/chat_service.dart';

class ChatController extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;

  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  /// بث مباشر للرسائل
  Stream<List<ChatMessageModel>> getMessageStream(String otherUserId) {
    return _chatService.getMessages(otherUserId);
  }

  /// تحميل الرسائل مرة واحدة
  Future<void> loadMessages(String otherUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final messageList = await _chatService.getMessages(otherUserId).first;
      _messages = messageList;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading messages: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// إرسال رسالة جديدة
  Future<void> sendMessage({
    required String receiverId,
    required String text,
    String? imageUrl,
  }) async {
    if (text.trim().isEmpty && imageUrl == null) return;

    try {
      await _chatService.sendMessage(
        receiverId: receiverId,
        text: text,
        imageUrl: imageUrl,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending message: $e');
      }
    }
  }

  /// تعديل رسالة
  Future<void> editMessage({
    required String messageId,
    required String newText,
  }) async {
    try {
      await _chatService.editMessage(messageId: messageId, newText: newText);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error editing message: $e');
      }
    }
  }

  /// حذف رسالة
  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatService.deleteMessage(messageId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting message: $e');
      }
    }
  }

  /// تعليم الرسائل كمقروءة
  Future<void> markMessagesAsRead(String otherUserId) async {
    try {
      await _chatService.markMessagesAsRead(otherUserId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error marking messages as read: $e');
      }
    }
  }
}

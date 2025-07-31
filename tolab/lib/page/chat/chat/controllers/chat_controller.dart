import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  /// تحميل الرسائل مرة واحدة عند الدخول
  Future<void> loadMessages(String otherUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _chatService.getMessages(otherUserId).listen((messageList) {
        _messages = messageList;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      if (kDebugMode) {
        print('❌ Error loading messages: $e');
      }
      notifyListeners();
    }
  }

  /// إرسال رسالة جديدة (نص أو صورة)
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
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending message: $e');
      }
    }
  }

  /// تعديل رسالة موجودة
  Future<void> editMessage({
    required String messageId,
    required String newText,
  }) async {
    try {
      await _chatService.editMessage(messageId: messageId, newText: newText);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error editing message: $e');
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

import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<ChatResponse> sendMessage({
    required String message,
    String? sessionId,
  });

  Future<List<ChatMessage>> getHistory(String sessionId);
}

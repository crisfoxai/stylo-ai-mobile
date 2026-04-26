import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    ChatRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

class ChatState {
  final List<ChatMessage> messages;
  final String? sessionId;
  final bool isSending;
  final String? errorMessage;
  final int? messagesUsedThisMonth;
  final int? messagesLimitThisMonth;

  const ChatState({
    this.messages = const [],
    this.sessionId,
    this.isSending = false,
    this.errorMessage,
    this.messagesUsedThisMonth,
    this.messagesLimitThisMonth,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    String? sessionId,
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
    int? messagesUsedThisMonth,
    int? messagesLimitThisMonth,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        sessionId: sessionId ?? this.sessionId,
        isSending: isSending ?? this.isSending,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        messagesUsedThisMonth:
            messagesUsedThisMonth ?? this.messagesUsedThisMonth,
        messagesLimitThisMonth:
            messagesLimitThisMonth ?? this.messagesLimitThisMonth,
      );
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;

  ChatNotifier(this._repository) : super(const ChatState());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isSending) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: text.trim(),
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isSending: true,
      clearError: true,
    );

    try {
      final response = await _repository.sendMessage(
        message: text.trim(),
        sessionId: state.sessionId,
      );

      final assistantMsg = ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_a',
        role: MessageRole.assistant,
        content: response.reply,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        sessionId: response.sessionId,
        isSending: false,
        messagesUsedThisMonth: response.messagesUsedThisMonth,
        messagesLimitThisMonth: response.messagesLimitThisMonth,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: _parseError(e),
      );
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  String _parseError(Object e) {
    if (e is DioException) {
      final body = e.response?.data;
      if (body is Map) {
        if (body['error'] == 'PLAN_LIMIT') {
          return 'Alcanzaste el límite de mensajes de tu plan';
        }
        if (body['error'] == 'SUBSCRIPTION_REQUIRED') {
          return 'Necesitás un plan para usar el chat';
        }
      }
    }
    return 'Error al enviar el mensaje';
  }
}

final chatProvider =
    StateNotifierProvider.autoDispose<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref.watch(chatRepositoryProvider));
});

import 'package:dio/dio.dart';
import '../../domain/entities/chat_message.dart';

class ChatRemoteDataSource {
  final Dio _dio;

  ChatRemoteDataSource(this._dio);

  Future<ChatResponse> sendMessage({
    required String message,
    String? sessionId,
  }) async {
    final body = <String, dynamic>{'message': message};
    if (sessionId != null) body['sessionId'] = sessionId;

    final response = await _dio.post('/chat/message', data: body);
    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>);
    return ChatResponse.fromJson(data);
  }

  Future<List<ChatMessage>> getHistory(String sessionId) async {
    final response = await _dio.get(
      '/chat/history',
      queryParameters: {'sessionId': sessionId},
    );
    final list = response.data is List
        ? response.data as List
        : (response.data['data'] as List);
    return list
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _dataSource;

  ChatRepositoryImpl(this._dataSource);

  @override
  Future<ChatResponse> sendMessage({
    required String message,
    String? sessionId,
  }) =>
      _dataSource.sendMessage(message: message, sessionId: sessionId);

  @override
  Future<List<ChatMessage>> getHistory(String sessionId) =>
      _dataSource.getHistory(sessionId);
}

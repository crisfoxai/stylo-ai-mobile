enum MessageRole { user, assistant }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final String? model;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.model,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      role: json['role'] == 'assistant' ? MessageRole.assistant : MessageRole.user,
      content: json['content'] as String,
      model: json['model'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

class ChatResponse {
  final String reply;
  final String sessionId;
  final int? messagesUsedThisMonth;
  final int? messagesLimitThisMonth;

  const ChatResponse({
    required this.reply,
    required this.sessionId,
    this.messagesUsedThisMonth,
    this.messagesLimitThisMonth,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      reply: json['reply'] as String,
      sessionId: json['sessionId'] as String,
      messagesUsedThisMonth: json['messagesUsedThisMonth'] as int?,
      messagesLimitThisMonth: json['messagesLimitThisMonth'] as int?,
    );
  }
}

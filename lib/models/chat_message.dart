import 'dart:convert';

class ChatMessage {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final String timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    String? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().toIso8601String();

  bool get isUser => role == 'user';

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'content': content,
        'timestamp': timestamp,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'],
        role: json['role'],
        content: json['content'],
        timestamp: json['timestamp'],
      );

  static List<ChatMessage> fromJsonList(String str) {
    final List<dynamic> list = jsonDecode(str);
    return list.map((e) => ChatMessage.fromJson(e)).toList();
  }

  static String toJsonList(List<ChatMessage> messages) =>
      jsonEncode(messages.map((e) => e.toJson()).toList());
}

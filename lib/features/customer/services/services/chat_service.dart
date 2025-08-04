import 'package:jinbeanpod_83904710/features/customer/services/presentation/service_detail_controller.dart';

/// 聊天服务接口
abstract class ChatService {
  /// 获取聊天会话列表
  Future<List<ChatSession>> getChatSessions();
  
  /// 获取指定会话的消息列表
  Future<List<ChatMessage>> getMessages(String sessionId, {int? limit, int? offset});
  
  /// 发送消息
  Future<ChatMessage> sendMessage(String sessionId, MessageContent content);
  
  /// 创建新的聊天会话
  Future<ChatSession> createChatSession(String providerId, String serviceId);
  
  /// 获取未读消息数量
  Future<int> getUnreadCount(String sessionId);
  
  /// 标记消息为已读
  Future<void> markAsRead(String sessionId, List<String> messageIds);
  
  /// 发送语音消息
  Future<ChatMessage> sendVoiceMessage(String sessionId, String audioUrl, int duration);
  
  /// 发送图片消息
  Future<ChatMessage> sendImageMessage(String sessionId, String imageUrl);
  
  /// 发送文件消息
  Future<ChatMessage> sendFileMessage(String sessionId, String fileUrl, String fileName);
}

/// 聊天会话模型
class ChatSession {
  final String id;
  final String providerId;
  final String serviceId;
  final String providerName;
  final String? providerAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final DateTime createdAt;
  final String status; // 'active', 'archived', 'blocked'

  ChatSession({
    required this.id,
    required this.providerId,
    required this.serviceId,
    required this.providerName,
    this.providerAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.createdAt,
    required this.status,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      providerId: json['provider_id'],
      serviceId: json['service_id'],
      providerName: json['provider_name'],
      providerAvatar: json['provider_avatar'],
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: DateTime.parse(json['last_message_time']),
      unreadCount: json['unread_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'] ?? 'active',
    );
  }
}

/// 聊天消息模型
class ChatMessage {
  final String id;
  final String sessionId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final MessageContent content;
  final DateTime timestamp;
  final bool isRead;
  final String status; // 'sent', 'delivered', 'read', 'failed'

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.status,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      sessionId: json['session_id'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      senderAvatar: json['sender_avatar'],
      content: MessageContent.fromJson(json['content']),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['is_read'] ?? false,
      status: json['status'] ?? 'sent',
    );
  }
}

/// 消息内容模型
class MessageContent {
  final String type; // 'text', 'image', 'voice', 'file', 'location'
  final String content;
  final Map<String, dynamic>? metadata;

  MessageContent({
    required this.type,
    required this.content,
    this.metadata,
  });

  factory MessageContent.fromJson(Map<String, dynamic> json) {
    return MessageContent(
      type: json['type'],
      content: json['content'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'content': content,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// MsgNexus服务实现
class MsgNexusService implements ChatService {
  final String apiKey;
  final String baseUrl;
  
  MsgNexusService(this.apiKey, {this.baseUrl = 'https://api.msgnexus.com/v1'});

  @override
  Future<List<ChatSession>> getChatSessions() async {
    // 模拟实现
    await Future.delayed(Duration(milliseconds: 300));
    
    return [
      ChatSession(
        id: 'session_1',
        providerId: 'provider_456',
        serviceId: 'service_123',
        providerName: 'CleanPro Services',
        providerAvatar: 'https://picsum.photos/50/50?random=1',
        lastMessage: 'Hi! I can help you with your cleaning needs.',
        lastMessageTime: DateTime.now().subtract(Duration(minutes: 5)),
        unreadCount: 1,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        status: 'active',
      ),
    ];
  }

  @override
  Future<List<ChatMessage>> getMessages(String sessionId, {int? limit, int? offset}) async {
    // 模拟实现
    await Future.delayed(Duration(milliseconds: 200));
    
    return [
      ChatMessage(
        id: 'msg_1',
        sessionId: sessionId,
        senderId: 'provider_456',
        senderName: 'CleanPro Services',
        senderAvatar: 'https://picsum.photos/50/50?random=1',
        content: MessageContent(type: 'text', content: 'Hi! I can help you with your cleaning needs.'),
        timestamp: DateTime.now().subtract(Duration(minutes: 5)),
        isRead: false,
        status: 'delivered',
      ),
      ChatMessage(
        id: 'msg_2',
        sessionId: sessionId,
        senderId: 'user_123',
        senderName: 'You',
        content: MessageContent(type: 'text', content: 'Great! I need cleaning for my 2-bedroom apartment.'),
        timestamp: DateTime.now().subtract(Duration(minutes: 3)),
        isRead: true,
        status: 'read',
      ),
    ];
  }

  @override
  Future<ChatMessage> sendMessage(String sessionId, MessageContent content) async {
    // 模拟实现
    await Future.delayed(Duration(milliseconds: 500));
    
    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      senderId: 'user_123',
      senderName: 'You',
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
      status: 'sent',
    );
  }

  @override
  Future<ChatSession> createChatSession(String providerId, String serviceId) async {
    // 模拟实现
    await Future.delayed(Duration(milliseconds: 400));
    
    return ChatSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      providerId: providerId,
      serviceId: serviceId,
      providerName: 'Provider',
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      createdAt: DateTime.now(),
      status: 'active',
    );
  }

  @override
  Future<int> getUnreadCount(String sessionId) async {
    // 模拟实现
    return 1;
  }

  @override
  Future<void> markAsRead(String sessionId, List<String> messageIds) async {
    // 模拟实现
    await Future.delayed(Duration(milliseconds: 100));
  }

  @override
  Future<ChatMessage> sendVoiceMessage(String sessionId, String audioUrl, int duration) async {
    return sendMessage(sessionId, MessageContent(
      type: 'voice',
      content: audioUrl,
      metadata: {'duration': duration},
    ));
  }

  @override
  Future<ChatMessage> sendImageMessage(String sessionId, String imageUrl) async {
    return sendMessage(sessionId, MessageContent(
      type: 'image',
      content: imageUrl,
    ));
  }

  @override
  Future<ChatMessage> sendFileMessage(String sessionId, String fileUrl, String fileName) async {
    return sendMessage(sessionId, MessageContent(
      type: 'file',
      content: fileUrl,
      metadata: {'fileName': fileName},
    ));
  }
} 
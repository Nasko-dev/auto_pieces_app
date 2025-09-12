// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationImpl _$$ConversationImplFromJson(Map<String, dynamic> json) =>
    _$ConversationImpl(
      id: json['id'] as String,
      requestId: json['requestId'] as String,
      userId: json['userId'] as String,
      sellerId: json['sellerId'] as String,
      status:
          $enumDecodeNullable(_$ConversationStatusEnumMap, json['status']) ??
              ConversationStatus.active,
      lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      sellerName: json['sellerName'] as String?,
      sellerCompany: json['sellerCompany'] as String?,
      requestTitle: json['requestTitle'] as String?,
      lastMessageContent: json['lastMessageContent'] as String?,
      lastMessageSenderType: $enumDecodeNullable(
          _$MessageSenderTypeEnumMap, json['lastMessageSenderType']),
      lastMessageCreatedAt: json['lastMessageCreatedAt'] == null
          ? null
          : DateTime.parse(json['lastMessageCreatedAt'] as String),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      totalMessages: (json['totalMessages'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ConversationImplToJson(_$ConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requestId': instance.requestId,
      'userId': instance.userId,
      'sellerId': instance.sellerId,
      'status': _$ConversationStatusEnumMap[instance.status]!,
      'lastMessageAt': instance.lastMessageAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'sellerName': instance.sellerName,
      'sellerCompany': instance.sellerCompany,
      'requestTitle': instance.requestTitle,
      'lastMessageContent': instance.lastMessageContent,
      'lastMessageSenderType':
          _$MessageSenderTypeEnumMap[instance.lastMessageSenderType],
      'lastMessageCreatedAt': instance.lastMessageCreatedAt?.toIso8601String(),
      'unreadCount': instance.unreadCount,
      'totalMessages': instance.totalMessages,
    };

const _$ConversationStatusEnumMap = {
  ConversationStatus.active: 'active',
  ConversationStatus.closed: 'closed',
  ConversationStatus.deletedByUser: 'deletedByUser',
  ConversationStatus.blockedByUser: 'blockedByUser',
};

const _$MessageSenderTypeEnumMap = {
  MessageSenderType.user: 'user',
  MessageSenderType.seller: 'seller',
};

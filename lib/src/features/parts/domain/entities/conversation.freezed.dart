// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Conversation _$ConversationFromJson(Map<String, dynamic> json) {
  return _Conversation.fromJson(json);
}

/// @nodoc
mixin _$Conversation {
  String get id => throw _privateConstructorUsedError;
  String get requestId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get sellerId => throw _privateConstructorUsedError;
  ConversationStatus get status => throw _privateConstructorUsedError;
  DateTime get lastMessageAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get sellerName => throw _privateConstructorUsedError;
  String? get sellerCompany => throw _privateConstructorUsedError;
  String? get requestTitle => throw _privateConstructorUsedError;
  String? get lastMessageContent => throw _privateConstructorUsedError;
  MessageSenderType? get lastMessageSenderType =>
      throw _privateConstructorUsedError;
  DateTime? get lastMessageCreatedAt => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  int get totalMessages => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConversationCopyWith<Conversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationCopyWith<$Res> {
  factory $ConversationCopyWith(
          Conversation value, $Res Function(Conversation) then) =
      _$ConversationCopyWithImpl<$Res, Conversation>;
  @useResult
  $Res call(
      {String id,
      String requestId,
      String userId,
      String sellerId,
      ConversationStatus status,
      DateTime lastMessageAt,
      DateTime createdAt,
      DateTime updatedAt,
      String? sellerName,
      String? sellerCompany,
      String? requestTitle,
      String? lastMessageContent,
      MessageSenderType? lastMessageSenderType,
      DateTime? lastMessageCreatedAt,
      int unreadCount,
      int totalMessages});
}

/// @nodoc
class _$ConversationCopyWithImpl<$Res, $Val extends Conversation>
    implements $ConversationCopyWith<$Res> {
  _$ConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requestId = null,
    Object? userId = null,
    Object? sellerId = null,
    Object? status = null,
    Object? lastMessageAt = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? sellerName = freezed,
    Object? sellerCompany = freezed,
    Object? requestTitle = freezed,
    Object? lastMessageContent = freezed,
    Object? lastMessageSenderType = freezed,
    Object? lastMessageCreatedAt = freezed,
    Object? unreadCount = null,
    Object? totalMessages = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      requestId: null == requestId
          ? _value.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      sellerId: null == sellerId
          ? _value.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ConversationStatus,
      lastMessageAt: null == lastMessageAt
          ? _value.lastMessageAt
          : lastMessageAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sellerName: freezed == sellerName
          ? _value.sellerName
          : sellerName // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerCompany: freezed == sellerCompany
          ? _value.sellerCompany
          : sellerCompany // ignore: cast_nullable_to_non_nullable
              as String?,
      requestTitle: freezed == requestTitle
          ? _value.requestTitle
          : requestTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageContent: freezed == lastMessageContent
          ? _value.lastMessageContent
          : lastMessageContent // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageSenderType: freezed == lastMessageSenderType
          ? _value.lastMessageSenderType
          : lastMessageSenderType // ignore: cast_nullable_to_non_nullable
              as MessageSenderType?,
      lastMessageCreatedAt: freezed == lastMessageCreatedAt
          ? _value.lastMessageCreatedAt
          : lastMessageCreatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalMessages: null == totalMessages
          ? _value.totalMessages
          : totalMessages // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConversationImplCopyWith<$Res>
    implements $ConversationCopyWith<$Res> {
  factory _$$ConversationImplCopyWith(
          _$ConversationImpl value, $Res Function(_$ConversationImpl) then) =
      __$$ConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String requestId,
      String userId,
      String sellerId,
      ConversationStatus status,
      DateTime lastMessageAt,
      DateTime createdAt,
      DateTime updatedAt,
      String? sellerName,
      String? sellerCompany,
      String? requestTitle,
      String? lastMessageContent,
      MessageSenderType? lastMessageSenderType,
      DateTime? lastMessageCreatedAt,
      int unreadCount,
      int totalMessages});
}

/// @nodoc
class __$$ConversationImplCopyWithImpl<$Res>
    extends _$ConversationCopyWithImpl<$Res, _$ConversationImpl>
    implements _$$ConversationImplCopyWith<$Res> {
  __$$ConversationImplCopyWithImpl(
      _$ConversationImpl _value, $Res Function(_$ConversationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requestId = null,
    Object? userId = null,
    Object? sellerId = null,
    Object? status = null,
    Object? lastMessageAt = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? sellerName = freezed,
    Object? sellerCompany = freezed,
    Object? requestTitle = freezed,
    Object? lastMessageContent = freezed,
    Object? lastMessageSenderType = freezed,
    Object? lastMessageCreatedAt = freezed,
    Object? unreadCount = null,
    Object? totalMessages = null,
  }) {
    return _then(_$ConversationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      requestId: null == requestId
          ? _value.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      sellerId: null == sellerId
          ? _value.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ConversationStatus,
      lastMessageAt: null == lastMessageAt
          ? _value.lastMessageAt
          : lastMessageAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sellerName: freezed == sellerName
          ? _value.sellerName
          : sellerName // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerCompany: freezed == sellerCompany
          ? _value.sellerCompany
          : sellerCompany // ignore: cast_nullable_to_non_nullable
              as String?,
      requestTitle: freezed == requestTitle
          ? _value.requestTitle
          : requestTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageContent: freezed == lastMessageContent
          ? _value.lastMessageContent
          : lastMessageContent // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageSenderType: freezed == lastMessageSenderType
          ? _value.lastMessageSenderType
          : lastMessageSenderType // ignore: cast_nullable_to_non_nullable
              as MessageSenderType?,
      lastMessageCreatedAt: freezed == lastMessageCreatedAt
          ? _value.lastMessageCreatedAt
          : lastMessageCreatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalMessages: null == totalMessages
          ? _value.totalMessages
          : totalMessages // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConversationImpl implements _Conversation {
  const _$ConversationImpl(
      {required this.id,
      required this.requestId,
      required this.userId,
      required this.sellerId,
      this.status = ConversationStatus.active,
      required this.lastMessageAt,
      required this.createdAt,
      required this.updatedAt,
      this.sellerName,
      this.sellerCompany,
      this.requestTitle,
      this.lastMessageContent,
      this.lastMessageSenderType,
      this.lastMessageCreatedAt,
      this.unreadCount = 0,
      this.totalMessages = 0});

  factory _$ConversationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationImplFromJson(json);

  @override
  final String id;
  @override
  final String requestId;
  @override
  final String userId;
  @override
  final String sellerId;
  @override
  @JsonKey()
  final ConversationStatus status;
  @override
  final DateTime lastMessageAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? sellerName;
  @override
  final String? sellerCompany;
  @override
  final String? requestTitle;
  @override
  final String? lastMessageContent;
  @override
  final MessageSenderType? lastMessageSenderType;
  @override
  final DateTime? lastMessageCreatedAt;
  @override
  @JsonKey()
  final int unreadCount;
  @override
  @JsonKey()
  final int totalMessages;

  @override
  String toString() {
    return 'Conversation(id: $id, requestId: $requestId, userId: $userId, sellerId: $sellerId, status: $status, lastMessageAt: $lastMessageAt, createdAt: $createdAt, updatedAt: $updatedAt, sellerName: $sellerName, sellerCompany: $sellerCompany, requestTitle: $requestTitle, lastMessageContent: $lastMessageContent, lastMessageSenderType: $lastMessageSenderType, lastMessageCreatedAt: $lastMessageCreatedAt, unreadCount: $unreadCount, totalMessages: $totalMessages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.sellerId, sellerId) ||
                other.sellerId == sellerId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.sellerName, sellerName) ||
                other.sellerName == sellerName) &&
            (identical(other.sellerCompany, sellerCompany) ||
                other.sellerCompany == sellerCompany) &&
            (identical(other.requestTitle, requestTitle) ||
                other.requestTitle == requestTitle) &&
            (identical(other.lastMessageContent, lastMessageContent) ||
                other.lastMessageContent == lastMessageContent) &&
            (identical(other.lastMessageSenderType, lastMessageSenderType) ||
                other.lastMessageSenderType == lastMessageSenderType) &&
            (identical(other.lastMessageCreatedAt, lastMessageCreatedAt) ||
                other.lastMessageCreatedAt == lastMessageCreatedAt) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.totalMessages, totalMessages) ||
                other.totalMessages == totalMessages));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      requestId,
      userId,
      sellerId,
      status,
      lastMessageAt,
      createdAt,
      updatedAt,
      sellerName,
      sellerCompany,
      requestTitle,
      lastMessageContent,
      lastMessageSenderType,
      lastMessageCreatedAt,
      unreadCount,
      totalMessages);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      __$$ConversationImplCopyWithImpl<_$ConversationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationImplToJson(
      this,
    );
  }
}

abstract class _Conversation implements Conversation {
  const factory _Conversation(
      {required final String id,
      required final String requestId,
      required final String userId,
      required final String sellerId,
      final ConversationStatus status,
      required final DateTime lastMessageAt,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String? sellerName,
      final String? sellerCompany,
      final String? requestTitle,
      final String? lastMessageContent,
      final MessageSenderType? lastMessageSenderType,
      final DateTime? lastMessageCreatedAt,
      final int unreadCount,
      final int totalMessages}) = _$ConversationImpl;

  factory _Conversation.fromJson(Map<String, dynamic> json) =
      _$ConversationImpl.fromJson;

  @override
  String get id;
  @override
  String get requestId;
  @override
  String get userId;
  @override
  String get sellerId;
  @override
  ConversationStatus get status;
  @override
  DateTime get lastMessageAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get sellerName;
  @override
  String? get sellerCompany;
  @override
  String? get requestTitle;
  @override
  String? get lastMessageContent;
  @override
  MessageSenderType? get lastMessageSenderType;
  @override
  DateTime? get lastMessageCreatedAt;
  @override
  int get unreadCount;
  @override
  int get totalMessages;
  @override
  @JsonKey(ignore: true)
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

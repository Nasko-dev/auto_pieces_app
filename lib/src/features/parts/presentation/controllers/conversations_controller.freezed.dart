// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversations_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ConversationsState {
  List<Conversation> get conversations => throw _privateConstructorUsedError;
  Map<String, List<Message>> get conversationMessages =>
      throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingMessages => throw _privateConstructorUsedError;
  bool get isSendingMessage => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get activeConversationId => throw _privateConstructorUsedError;
  int get totalUnreadCount => throw _privateConstructorUsedError;

  /// Create a copy of ConversationsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationsStateCopyWith<ConversationsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationsStateCopyWith<$Res> {
  factory $ConversationsStateCopyWith(
          ConversationsState value, $Res Function(ConversationsState) then) =
      _$ConversationsStateCopyWithImpl<$Res, ConversationsState>;
  @useResult
  $Res call(
      {List<Conversation> conversations,
      Map<String, List<Message>> conversationMessages,
      bool isLoading,
      bool isLoadingMessages,
      bool isSendingMessage,
      String? error,
      String? activeConversationId,
      int totalUnreadCount});
}

/// @nodoc
class _$ConversationsStateCopyWithImpl<$Res, $Val extends ConversationsState>
    implements $ConversationsStateCopyWith<$Res> {
  _$ConversationsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversationsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversations = null,
    Object? conversationMessages = null,
    Object? isLoading = null,
    Object? isLoadingMessages = null,
    Object? isSendingMessage = null,
    Object? error = freezed,
    Object? activeConversationId = freezed,
    Object? totalUnreadCount = null,
  }) {
    return _then(_value.copyWith(
      conversations: null == conversations
          ? _value.conversations
          : conversations // ignore: cast_nullable_to_non_nullable
              as List<Conversation>,
      conversationMessages: null == conversationMessages
          ? _value.conversationMessages
          : conversationMessages // ignore: cast_nullable_to_non_nullable
              as Map<String, List<Message>>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMessages: null == isLoadingMessages
          ? _value.isLoadingMessages
          : isLoadingMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      isSendingMessage: null == isSendingMessage
          ? _value.isSendingMessage
          : isSendingMessage // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      activeConversationId: freezed == activeConversationId
          ? _value.activeConversationId
          : activeConversationId // ignore: cast_nullable_to_non_nullable
              as String?,
      totalUnreadCount: null == totalUnreadCount
          ? _value.totalUnreadCount
          : totalUnreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConversationsStateImplCopyWith<$Res>
    implements $ConversationsStateCopyWith<$Res> {
  factory _$$ConversationsStateImplCopyWith(_$ConversationsStateImpl value,
          $Res Function(_$ConversationsStateImpl) then) =
      __$$ConversationsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Conversation> conversations,
      Map<String, List<Message>> conversationMessages,
      bool isLoading,
      bool isLoadingMessages,
      bool isSendingMessage,
      String? error,
      String? activeConversationId,
      int totalUnreadCount});
}

/// @nodoc
class __$$ConversationsStateImplCopyWithImpl<$Res>
    extends _$ConversationsStateCopyWithImpl<$Res, _$ConversationsStateImpl>
    implements _$$ConversationsStateImplCopyWith<$Res> {
  __$$ConversationsStateImplCopyWithImpl(_$ConversationsStateImpl _value,
      $Res Function(_$ConversationsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConversationsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversations = null,
    Object? conversationMessages = null,
    Object? isLoading = null,
    Object? isLoadingMessages = null,
    Object? isSendingMessage = null,
    Object? error = freezed,
    Object? activeConversationId = freezed,
    Object? totalUnreadCount = null,
  }) {
    return _then(_$ConversationsStateImpl(
      conversations: null == conversations
          ? _value._conversations
          : conversations // ignore: cast_nullable_to_non_nullable
              as List<Conversation>,
      conversationMessages: null == conversationMessages
          ? _value._conversationMessages
          : conversationMessages // ignore: cast_nullable_to_non_nullable
              as Map<String, List<Message>>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMessages: null == isLoadingMessages
          ? _value.isLoadingMessages
          : isLoadingMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      isSendingMessage: null == isSendingMessage
          ? _value.isSendingMessage
          : isSendingMessage // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      activeConversationId: freezed == activeConversationId
          ? _value.activeConversationId
          : activeConversationId // ignore: cast_nullable_to_non_nullable
              as String?,
      totalUnreadCount: null == totalUnreadCount
          ? _value.totalUnreadCount
          : totalUnreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ConversationsStateImpl implements _ConversationsState {
  const _$ConversationsStateImpl(
      {final List<Conversation> conversations = const [],
      final Map<String, List<Message>> conversationMessages = const {},
      this.isLoading = false,
      this.isLoadingMessages = false,
      this.isSendingMessage = false,
      this.error,
      this.activeConversationId,
      this.totalUnreadCount = 0})
      : _conversations = conversations,
        _conversationMessages = conversationMessages;

  final List<Conversation> _conversations;
  @override
  @JsonKey()
  List<Conversation> get conversations {
    if (_conversations is EqualUnmodifiableListView) return _conversations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conversations);
  }

  final Map<String, List<Message>> _conversationMessages;
  @override
  @JsonKey()
  Map<String, List<Message>> get conversationMessages {
    if (_conversationMessages is EqualUnmodifiableMapView)
      return _conversationMessages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_conversationMessages);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isLoadingMessages;
  @override
  @JsonKey()
  final bool isSendingMessage;
  @override
  final String? error;
  @override
  final String? activeConversationId;
  @override
  @JsonKey()
  final int totalUnreadCount;

  @override
  String toString() {
    return 'ConversationsState(conversations: $conversations, conversationMessages: $conversationMessages, isLoading: $isLoading, isLoadingMessages: $isLoadingMessages, isSendingMessage: $isSendingMessage, error: $error, activeConversationId: $activeConversationId, totalUnreadCount: $totalUnreadCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationsStateImpl &&
            const DeepCollectionEquality()
                .equals(other._conversations, _conversations) &&
            const DeepCollectionEquality()
                .equals(other._conversationMessages, _conversationMessages) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingMessages, isLoadingMessages) ||
                other.isLoadingMessages == isLoadingMessages) &&
            (identical(other.isSendingMessage, isSendingMessage) ||
                other.isSendingMessage == isSendingMessage) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.activeConversationId, activeConversationId) ||
                other.activeConversationId == activeConversationId) &&
            (identical(other.totalUnreadCount, totalUnreadCount) ||
                other.totalUnreadCount == totalUnreadCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_conversations),
      const DeepCollectionEquality().hash(_conversationMessages),
      isLoading,
      isLoadingMessages,
      isSendingMessage,
      error,
      activeConversationId,
      totalUnreadCount);

  /// Create a copy of ConversationsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationsStateImplCopyWith<_$ConversationsStateImpl> get copyWith =>
      __$$ConversationsStateImplCopyWithImpl<_$ConversationsStateImpl>(
          this, _$identity);
}

abstract class _ConversationsState implements ConversationsState {
  const factory _ConversationsState(
      {final List<Conversation> conversations,
      final Map<String, List<Message>> conversationMessages,
      final bool isLoading,
      final bool isLoadingMessages,
      final bool isSendingMessage,
      final String? error,
      final String? activeConversationId,
      final int totalUnreadCount}) = _$ConversationsStateImpl;

  @override
  List<Conversation> get conversations;
  @override
  Map<String, List<Message>> get conversationMessages;
  @override
  bool get isLoading;
  @override
  bool get isLoadingMessages;
  @override
  bool get isSendingMessage;
  @override
  String? get error;
  @override
  String? get activeConversationId;
  @override
  int get totalUnreadCount;

  /// Create a copy of ConversationsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationsStateImplCopyWith<_$ConversationsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

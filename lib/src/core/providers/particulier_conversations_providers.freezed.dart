// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'particulier_conversations_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ParticulierConversationsState {
  List<ParticulierConversation> get conversations =>
      throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  int get unreadCount =>
      throw _privateConstructorUsedError; // ✅ SIMPLE: Compteur local par conversation
  Map<String, int> get localUnreadCounts => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ParticulierConversationsStateCopyWith<ParticulierConversationsState>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParticulierConversationsStateCopyWith<$Res> {
  factory $ParticulierConversationsStateCopyWith(
          ParticulierConversationsState value,
          $Res Function(ParticulierConversationsState) then) =
      _$ParticulierConversationsStateCopyWithImpl<$Res,
          ParticulierConversationsState>;
  @useResult
  $Res call(
      {List<ParticulierConversation> conversations,
      bool isLoading,
      String? error,
      int unreadCount,
      Map<String, int> localUnreadCounts});
}

/// @nodoc
class _$ParticulierConversationsStateCopyWithImpl<$Res,
        $Val extends ParticulierConversationsState>
    implements $ParticulierConversationsStateCopyWith<$Res> {
  _$ParticulierConversationsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversations = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? unreadCount = null,
    Object? localUnreadCounts = null,
  }) {
    return _then(_value.copyWith(
      conversations: null == conversations
          ? _value.conversations
          : conversations // ignore: cast_nullable_to_non_nullable
              as List<ParticulierConversation>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      localUnreadCounts: null == localUnreadCounts
          ? _value.localUnreadCounts
          : localUnreadCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ParticulierConversationsStateImplCopyWith<$Res>
    implements $ParticulierConversationsStateCopyWith<$Res> {
  factory _$$ParticulierConversationsStateImplCopyWith(
          _$ParticulierConversationsStateImpl value,
          $Res Function(_$ParticulierConversationsStateImpl) then) =
      __$$ParticulierConversationsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<ParticulierConversation> conversations,
      bool isLoading,
      String? error,
      int unreadCount,
      Map<String, int> localUnreadCounts});
}

/// @nodoc
class __$$ParticulierConversationsStateImplCopyWithImpl<$Res>
    extends _$ParticulierConversationsStateCopyWithImpl<$Res,
        _$ParticulierConversationsStateImpl>
    implements _$$ParticulierConversationsStateImplCopyWith<$Res> {
  __$$ParticulierConversationsStateImplCopyWithImpl(
      _$ParticulierConversationsStateImpl _value,
      $Res Function(_$ParticulierConversationsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversations = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? unreadCount = null,
    Object? localUnreadCounts = null,
  }) {
    return _then(_$ParticulierConversationsStateImpl(
      conversations: null == conversations
          ? _value._conversations
          : conversations // ignore: cast_nullable_to_non_nullable
              as List<ParticulierConversation>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      localUnreadCounts: null == localUnreadCounts
          ? _value._localUnreadCounts
          : localUnreadCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc

class _$ParticulierConversationsStateImpl
    implements _ParticulierConversationsState {
  const _$ParticulierConversationsStateImpl(
      {final List<ParticulierConversation> conversations = const [],
      this.isLoading = false,
      this.error,
      this.unreadCount = 0,
      final Map<String, int> localUnreadCounts = const {}})
      : _conversations = conversations,
        _localUnreadCounts = localUnreadCounts;

  final List<ParticulierConversation> _conversations;
  @override
  @JsonKey()
  List<ParticulierConversation> get conversations {
    if (_conversations is EqualUnmodifiableListView) return _conversations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conversations);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  @JsonKey()
  final int unreadCount;
// ✅ SIMPLE: Compteur local par conversation
  final Map<String, int> _localUnreadCounts;
// ✅ SIMPLE: Compteur local par conversation
  @override
  @JsonKey()
  Map<String, int> get localUnreadCounts {
    if (_localUnreadCounts is EqualUnmodifiableMapView)
      return _localUnreadCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_localUnreadCounts);
  }

  @override
  String toString() {
    return 'ParticulierConversationsState(conversations: $conversations, isLoading: $isLoading, error: $error, unreadCount: $unreadCount, localUnreadCounts: $localUnreadCounts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParticulierConversationsStateImpl &&
            const DeepCollectionEquality()
                .equals(other._conversations, _conversations) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            const DeepCollectionEquality()
                .equals(other._localUnreadCounts, _localUnreadCounts));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_conversations),
      isLoading,
      error,
      unreadCount,
      const DeepCollectionEquality().hash(_localUnreadCounts));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ParticulierConversationsStateImplCopyWith<
          _$ParticulierConversationsStateImpl>
      get copyWith => __$$ParticulierConversationsStateImplCopyWithImpl<
          _$ParticulierConversationsStateImpl>(this, _$identity);
}

abstract class _ParticulierConversationsState
    implements ParticulierConversationsState {
  const factory _ParticulierConversationsState(
          {final List<ParticulierConversation> conversations,
          final bool isLoading,
          final String? error,
          final int unreadCount,
          final Map<String, int> localUnreadCounts}) =
      _$ParticulierConversationsStateImpl;

  @override
  List<ParticulierConversation> get conversations;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  int get unreadCount;
  @override // ✅ SIMPLE: Compteur local par conversation
  Map<String, int> get localUnreadCounts;
  @override
  @JsonKey(ignore: true)
  _$$ParticulierConversationsStateImplCopyWith<
          _$ParticulierConversationsStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

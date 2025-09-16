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
  String? get activeConversationId => throw _privateConstructorUsedError;

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
      String? activeConversationId});
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
    Object? activeConversationId = freezed,
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
      activeConversationId: freezed == activeConversationId
          ? _value.activeConversationId
          : activeConversationId // ignore: cast_nullable_to_non_nullable
              as String?,
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
      String? activeConversationId});
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
    Object? activeConversationId = freezed,
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
      activeConversationId: freezed == activeConversationId
          ? _value.activeConversationId
          : activeConversationId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ParticulierConversationsStateImpl extends _ParticulierConversationsState
    with DiagnosticableTreeMixin {
  const _$ParticulierConversationsStateImpl(
      {final List<ParticulierConversation> conversations = const [],
      this.isLoading = false,
      this.error,
      this.activeConversationId})
      : _conversations = conversations,
        super._();

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
  final String? activeConversationId;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ParticulierConversationsState(conversations: $conversations, isLoading: $isLoading, error: $error, activeConversationId: $activeConversationId)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ParticulierConversationsState'))
      ..add(DiagnosticsProperty('conversations', conversations))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('activeConversationId', activeConversationId));
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
            (identical(other.activeConversationId, activeConversationId) ||
                other.activeConversationId == activeConversationId));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_conversations),
      isLoading,
      error,
      activeConversationId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ParticulierConversationsStateImplCopyWith<
          _$ParticulierConversationsStateImpl>
      get copyWith => __$$ParticulierConversationsStateImplCopyWithImpl<
          _$ParticulierConversationsStateImpl>(this, _$identity);
}

abstract class _ParticulierConversationsState
    extends ParticulierConversationsState {
  const factory _ParticulierConversationsState(
          {final List<ParticulierConversation> conversations,
          final bool isLoading,
          final String? error,
          final String? activeConversationId}) =
      _$ParticulierConversationsStateImpl;
  const _ParticulierConversationsState._() : super._();

  @override
  List<ParticulierConversation> get conversations;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  String? get activeConversationId;
  @override
  @JsonKey(ignore: true)
  _$$ParticulierConversationsStateImplCopyWith<
          _$ParticulierConversationsStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

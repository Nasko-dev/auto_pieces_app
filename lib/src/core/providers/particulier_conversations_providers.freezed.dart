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
  int get demandesCount =>
      throw _privateConstructorUsedError; // Count rapide des demandes
  int get annoncesCount =>
      throw _privateConstructorUsedError; // Count rapide des annonces
  bool get isLoadingAnnonces =>
      throw _privateConstructorUsedError; // Chargement en cours des annonces
  DateTime? get lastLoadedAt =>
      throw _privateConstructorUsedError; // Timestamp du dernier chargement pour cache intelligent
  bool get needsReload => throw _privateConstructorUsedError;

  /// Create a copy of ParticulierConversationsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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
      String? activeConversationId,
      int demandesCount,
      int annoncesCount,
      bool isLoadingAnnonces,
      DateTime? lastLoadedAt,
      bool needsReload});
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

  /// Create a copy of ParticulierConversationsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversations = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? activeConversationId = freezed,
    Object? demandesCount = null,
    Object? annoncesCount = null,
    Object? isLoadingAnnonces = null,
    Object? lastLoadedAt = freezed,
    Object? needsReload = null,
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
      demandesCount: null == demandesCount
          ? _value.demandesCount
          : demandesCount // ignore: cast_nullable_to_non_nullable
              as int,
      annoncesCount: null == annoncesCount
          ? _value.annoncesCount
          : annoncesCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLoadingAnnonces: null == isLoadingAnnonces
          ? _value.isLoadingAnnonces
          : isLoadingAnnonces // ignore: cast_nullable_to_non_nullable
              as bool,
      lastLoadedAt: freezed == lastLoadedAt
          ? _value.lastLoadedAt
          : lastLoadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      needsReload: null == needsReload
          ? _value.needsReload
          : needsReload // ignore: cast_nullable_to_non_nullable
              as bool,
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
      String? activeConversationId,
      int demandesCount,
      int annoncesCount,
      bool isLoadingAnnonces,
      DateTime? lastLoadedAt,
      bool needsReload});
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

  /// Create a copy of ParticulierConversationsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversations = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? activeConversationId = freezed,
    Object? demandesCount = null,
    Object? annoncesCount = null,
    Object? isLoadingAnnonces = null,
    Object? lastLoadedAt = freezed,
    Object? needsReload = null,
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
      demandesCount: null == demandesCount
          ? _value.demandesCount
          : demandesCount // ignore: cast_nullable_to_non_nullable
              as int,
      annoncesCount: null == annoncesCount
          ? _value.annoncesCount
          : annoncesCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLoadingAnnonces: null == isLoadingAnnonces
          ? _value.isLoadingAnnonces
          : isLoadingAnnonces // ignore: cast_nullable_to_non_nullable
              as bool,
      lastLoadedAt: freezed == lastLoadedAt
          ? _value.lastLoadedAt
          : lastLoadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      needsReload: null == needsReload
          ? _value.needsReload
          : needsReload // ignore: cast_nullable_to_non_nullable
              as bool,
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
      this.activeConversationId,
      this.demandesCount = 0,
      this.annoncesCount = 0,
      this.isLoadingAnnonces = false,
      this.lastLoadedAt,
      this.needsReload = false})
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
  @JsonKey()
  final int demandesCount;
// Count rapide des demandes
  @override
  @JsonKey()
  final int annoncesCount;
// Count rapide des annonces
  @override
  @JsonKey()
  final bool isLoadingAnnonces;
// Chargement en cours des annonces
  @override
  final DateTime? lastLoadedAt;
// Timestamp du dernier chargement pour cache intelligent
  @override
  @JsonKey()
  final bool needsReload;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ParticulierConversationsState(conversations: $conversations, isLoading: $isLoading, error: $error, activeConversationId: $activeConversationId, demandesCount: $demandesCount, annoncesCount: $annoncesCount, isLoadingAnnonces: $isLoadingAnnonces, lastLoadedAt: $lastLoadedAt, needsReload: $needsReload)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ParticulierConversationsState'))
      ..add(DiagnosticsProperty('conversations', conversations))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('activeConversationId', activeConversationId))
      ..add(DiagnosticsProperty('demandesCount', demandesCount))
      ..add(DiagnosticsProperty('annoncesCount', annoncesCount))
      ..add(DiagnosticsProperty('isLoadingAnnonces', isLoadingAnnonces))
      ..add(DiagnosticsProperty('lastLoadedAt', lastLoadedAt))
      ..add(DiagnosticsProperty('needsReload', needsReload));
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
                other.activeConversationId == activeConversationId) &&
            (identical(other.demandesCount, demandesCount) ||
                other.demandesCount == demandesCount) &&
            (identical(other.annoncesCount, annoncesCount) ||
                other.annoncesCount == annoncesCount) &&
            (identical(other.isLoadingAnnonces, isLoadingAnnonces) ||
                other.isLoadingAnnonces == isLoadingAnnonces) &&
            (identical(other.lastLoadedAt, lastLoadedAt) ||
                other.lastLoadedAt == lastLoadedAt) &&
            (identical(other.needsReload, needsReload) ||
                other.needsReload == needsReload));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_conversations),
      isLoading,
      error,
      activeConversationId,
      demandesCount,
      annoncesCount,
      isLoadingAnnonces,
      lastLoadedAt,
      needsReload);

  /// Create a copy of ParticulierConversationsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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
      final String? activeConversationId,
      final int demandesCount,
      final int annoncesCount,
      final bool isLoadingAnnonces,
      final DateTime? lastLoadedAt,
      final bool needsReload}) = _$ParticulierConversationsStateImpl;
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
  int get demandesCount; // Count rapide des demandes
  @override
  int get annoncesCount; // Count rapide des annonces
  @override
  bool get isLoadingAnnonces; // Chargement en cours des annonces
  @override
  DateTime?
      get lastLoadedAt; // Timestamp du dernier chargement pour cache intelligent
  @override
  bool get needsReload;

  /// Create a copy of ParticulierConversationsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParticulierConversationsStateImplCopyWith<
          _$ParticulierConversationsStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seller_rejection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SellerRejection {
  String get id => throw _privateConstructorUsedError;
  String get sellerId => throw _privateConstructorUsedError;
  String get partRequestId => throw _privateConstructorUsedError;
  DateTime get rejectedAt => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of SellerRejection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SellerRejectionCopyWith<SellerRejection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SellerRejectionCopyWith<$Res> {
  factory $SellerRejectionCopyWith(
          SellerRejection value, $Res Function(SellerRejection) then) =
      _$SellerRejectionCopyWithImpl<$Res, SellerRejection>;
  @useResult
  $Res call(
      {String id,
      String sellerId,
      String partRequestId,
      DateTime rejectedAt,
      String? reason,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$SellerRejectionCopyWithImpl<$Res, $Val extends SellerRejection>
    implements $SellerRejectionCopyWith<$Res> {
  _$SellerRejectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SellerRejection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sellerId = null,
    Object? partRequestId = null,
    Object? rejectedAt = null,
    Object? reason = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sellerId: null == sellerId
          ? _value.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String,
      partRequestId: null == partRequestId
          ? _value.partRequestId
          : partRequestId // ignore: cast_nullable_to_non_nullable
              as String,
      rejectedAt: null == rejectedAt
          ? _value.rejectedAt
          : rejectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SellerRejectionImplCopyWith<$Res>
    implements $SellerRejectionCopyWith<$Res> {
  factory _$$SellerRejectionImplCopyWith(_$SellerRejectionImpl value,
          $Res Function(_$SellerRejectionImpl) then) =
      __$$SellerRejectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String sellerId,
      String partRequestId,
      DateTime rejectedAt,
      String? reason,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$SellerRejectionImplCopyWithImpl<$Res>
    extends _$SellerRejectionCopyWithImpl<$Res, _$SellerRejectionImpl>
    implements _$$SellerRejectionImplCopyWith<$Res> {
  __$$SellerRejectionImplCopyWithImpl(
      _$SellerRejectionImpl _value, $Res Function(_$SellerRejectionImpl) _then)
      : super(_value, _then);

  /// Create a copy of SellerRejection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sellerId = null,
    Object? partRequestId = null,
    Object? rejectedAt = null,
    Object? reason = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$SellerRejectionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sellerId: null == sellerId
          ? _value.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String,
      partRequestId: null == partRequestId
          ? _value.partRequestId
          : partRequestId // ignore: cast_nullable_to_non_nullable
              as String,
      rejectedAt: null == rejectedAt
          ? _value.rejectedAt
          : rejectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$SellerRejectionImpl implements _SellerRejection {
  const _$SellerRejectionImpl(
      {required this.id,
      required this.sellerId,
      required this.partRequestId,
      required this.rejectedAt,
      this.reason,
      required this.createdAt,
      required this.updatedAt});

  @override
  final String id;
  @override
  final String sellerId;
  @override
  final String partRequestId;
  @override
  final DateTime rejectedAt;
  @override
  final String? reason;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SellerRejection(id: $id, sellerId: $sellerId, partRequestId: $partRequestId, rejectedAt: $rejectedAt, reason: $reason, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SellerRejectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sellerId, sellerId) ||
                other.sellerId == sellerId) &&
            (identical(other.partRequestId, partRequestId) ||
                other.partRequestId == partRequestId) &&
            (identical(other.rejectedAt, rejectedAt) ||
                other.rejectedAt == rejectedAt) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, sellerId, partRequestId,
      rejectedAt, reason, createdAt, updatedAt);

  /// Create a copy of SellerRejection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SellerRejectionImplCopyWith<_$SellerRejectionImpl> get copyWith =>
      __$$SellerRejectionImplCopyWithImpl<_$SellerRejectionImpl>(
          this, _$identity);
}

abstract class _SellerRejection implements SellerRejection {
  const factory _SellerRejection(
      {required final String id,
      required final String sellerId,
      required final String partRequestId,
      required final DateTime rejectedAt,
      final String? reason,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$SellerRejectionImpl;

  @override
  String get id;
  @override
  String get sellerId;
  @override
  String get partRequestId;
  @override
  DateTime get rejectedAt;
  @override
  String? get reason;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of SellerRejection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SellerRejectionImplCopyWith<_$SellerRejectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

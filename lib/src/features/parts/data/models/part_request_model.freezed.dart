// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'part_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PartRequestModel _$PartRequestModelFromJson(Map<String, dynamic> json) {
  return _PartRequestModel.fromJson(json);
}

/// @nodoc
mixin _$PartRequestModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String? get userId =>
      throw _privateConstructorUsedError; // Informations du véhicule
  @JsonKey(name: 'vehicle_plate')
  String? get vehiclePlate => throw _privateConstructorUsedError;
  @JsonKey(name: 'vehicle_brand')
  String? get vehicleBrand => throw _privateConstructorUsedError;
  @JsonKey(name: 'vehicle_model')
  String? get vehicleModel => throw _privateConstructorUsedError;
  @JsonKey(name: 'vehicle_year')
  int? get vehicleYear => throw _privateConstructorUsedError;
  @JsonKey(name: 'vehicle_engine')
  String? get vehicleEngine =>
      throw _privateConstructorUsedError; // Type de pièce recherchée
  @JsonKey(name: 'part_type')
  String get partType => throw _privateConstructorUsedError;
  @JsonKey(name: 'part_names')
  List<String> get partNames => throw _privateConstructorUsedError;
  @JsonKey(name: 'additional_info')
  String? get additionalInfo =>
      throw _privateConstructorUsedError; // Métadonnées
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_anonymous')
  bool get isAnonymous => throw _privateConstructorUsedError;
  @JsonKey(name: 'response_count')
  int get responseCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'pending_response_count')
  int get pendingResponseCount =>
      throw _privateConstructorUsedError; // Timestamps
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this PartRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PartRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PartRequestModelCopyWith<PartRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartRequestModelCopyWith<$Res> {
  factory $PartRequestModelCopyWith(
          PartRequestModel value, $Res Function(PartRequestModel) then) =
      _$PartRequestModelCopyWithImpl<$Res, PartRequestModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String? userId,
      @JsonKey(name: 'vehicle_plate') String? vehiclePlate,
      @JsonKey(name: 'vehicle_brand') String? vehicleBrand,
      @JsonKey(name: 'vehicle_model') String? vehicleModel,
      @JsonKey(name: 'vehicle_year') int? vehicleYear,
      @JsonKey(name: 'vehicle_engine') String? vehicleEngine,
      @JsonKey(name: 'part_type') String partType,
      @JsonKey(name: 'part_names') List<String> partNames,
      @JsonKey(name: 'additional_info') String? additionalInfo,
      String status,
      @JsonKey(name: 'is_anonymous') bool isAnonymous,
      @JsonKey(name: 'response_count') int responseCount,
      @JsonKey(name: 'pending_response_count') int pendingResponseCount,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'expires_at') DateTime? expiresAt});
}

/// @nodoc
class _$PartRequestModelCopyWithImpl<$Res, $Val extends PartRequestModel>
    implements $PartRequestModelCopyWith<$Res> {
  _$PartRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PartRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? vehiclePlate = freezed,
    Object? vehicleBrand = freezed,
    Object? vehicleModel = freezed,
    Object? vehicleYear = freezed,
    Object? vehicleEngine = freezed,
    Object? partType = null,
    Object? partNames = null,
    Object? additionalInfo = freezed,
    Object? status = null,
    Object? isAnonymous = null,
    Object? responseCount = null,
    Object? pendingResponseCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      vehiclePlate: freezed == vehiclePlate
          ? _value.vehiclePlate
          : vehiclePlate // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleBrand: freezed == vehicleBrand
          ? _value.vehicleBrand
          : vehicleBrand // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleModel: freezed == vehicleModel
          ? _value.vehicleModel
          : vehicleModel // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleYear: freezed == vehicleYear
          ? _value.vehicleYear
          : vehicleYear // ignore: cast_nullable_to_non_nullable
              as int?,
      vehicleEngine: freezed == vehicleEngine
          ? _value.vehicleEngine
          : vehicleEngine // ignore: cast_nullable_to_non_nullable
              as String?,
      partType: null == partType
          ? _value.partType
          : partType // ignore: cast_nullable_to_non_nullable
              as String,
      partNames: null == partNames
          ? _value.partNames
          : partNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      additionalInfo: freezed == additionalInfo
          ? _value.additionalInfo
          : additionalInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isAnonymous: null == isAnonymous
          ? _value.isAnonymous
          : isAnonymous // ignore: cast_nullable_to_non_nullable
              as bool,
      responseCount: null == responseCount
          ? _value.responseCount
          : responseCount // ignore: cast_nullable_to_non_nullable
              as int,
      pendingResponseCount: null == pendingResponseCount
          ? _value.pendingResponseCount
          : pendingResponseCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PartRequestModelImplCopyWith<$Res>
    implements $PartRequestModelCopyWith<$Res> {
  factory _$$PartRequestModelImplCopyWith(_$PartRequestModelImpl value,
          $Res Function(_$PartRequestModelImpl) then) =
      __$$PartRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String? userId,
      @JsonKey(name: 'vehicle_plate') String? vehiclePlate,
      @JsonKey(name: 'vehicle_brand') String? vehicleBrand,
      @JsonKey(name: 'vehicle_model') String? vehicleModel,
      @JsonKey(name: 'vehicle_year') int? vehicleYear,
      @JsonKey(name: 'vehicle_engine') String? vehicleEngine,
      @JsonKey(name: 'part_type') String partType,
      @JsonKey(name: 'part_names') List<String> partNames,
      @JsonKey(name: 'additional_info') String? additionalInfo,
      String status,
      @JsonKey(name: 'is_anonymous') bool isAnonymous,
      @JsonKey(name: 'response_count') int responseCount,
      @JsonKey(name: 'pending_response_count') int pendingResponseCount,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'expires_at') DateTime? expiresAt});
}

/// @nodoc
class __$$PartRequestModelImplCopyWithImpl<$Res>
    extends _$PartRequestModelCopyWithImpl<$Res, _$PartRequestModelImpl>
    implements _$$PartRequestModelImplCopyWith<$Res> {
  __$$PartRequestModelImplCopyWithImpl(_$PartRequestModelImpl _value,
      $Res Function(_$PartRequestModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PartRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? vehiclePlate = freezed,
    Object? vehicleBrand = freezed,
    Object? vehicleModel = freezed,
    Object? vehicleYear = freezed,
    Object? vehicleEngine = freezed,
    Object? partType = null,
    Object? partNames = null,
    Object? additionalInfo = freezed,
    Object? status = null,
    Object? isAnonymous = null,
    Object? responseCount = null,
    Object? pendingResponseCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_$PartRequestModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      vehiclePlate: freezed == vehiclePlate
          ? _value.vehiclePlate
          : vehiclePlate // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleBrand: freezed == vehicleBrand
          ? _value.vehicleBrand
          : vehicleBrand // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleModel: freezed == vehicleModel
          ? _value.vehicleModel
          : vehicleModel // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleYear: freezed == vehicleYear
          ? _value.vehicleYear
          : vehicleYear // ignore: cast_nullable_to_non_nullable
              as int?,
      vehicleEngine: freezed == vehicleEngine
          ? _value.vehicleEngine
          : vehicleEngine // ignore: cast_nullable_to_non_nullable
              as String?,
      partType: null == partType
          ? _value.partType
          : partType // ignore: cast_nullable_to_non_nullable
              as String,
      partNames: null == partNames
          ? _value._partNames
          : partNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      additionalInfo: freezed == additionalInfo
          ? _value.additionalInfo
          : additionalInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isAnonymous: null == isAnonymous
          ? _value.isAnonymous
          : isAnonymous // ignore: cast_nullable_to_non_nullable
              as bool,
      responseCount: null == responseCount
          ? _value.responseCount
          : responseCount // ignore: cast_nullable_to_non_nullable
              as int,
      pendingResponseCount: null == pendingResponseCount
          ? _value.pendingResponseCount
          : pendingResponseCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PartRequestModelImpl extends _PartRequestModel {
  const _$PartRequestModelImpl(
      {required this.id,
      @JsonKey(name: 'user_id') this.userId,
      @JsonKey(name: 'vehicle_plate') this.vehiclePlate,
      @JsonKey(name: 'vehicle_brand') this.vehicleBrand,
      @JsonKey(name: 'vehicle_model') this.vehicleModel,
      @JsonKey(name: 'vehicle_year') this.vehicleYear,
      @JsonKey(name: 'vehicle_engine') this.vehicleEngine,
      @JsonKey(name: 'part_type') required this.partType,
      @JsonKey(name: 'part_names') required final List<String> partNames,
      @JsonKey(name: 'additional_info') this.additionalInfo,
      this.status = 'active',
      @JsonKey(name: 'is_anonymous') this.isAnonymous = false,
      @JsonKey(name: 'response_count') this.responseCount = 0,
      @JsonKey(name: 'pending_response_count') this.pendingResponseCount = 0,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'expires_at') this.expiresAt})
      : _partNames = partNames,
        super._();

  factory _$PartRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PartRequestModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String? userId;
// Informations du véhicule
  @override
  @JsonKey(name: 'vehicle_plate')
  final String? vehiclePlate;
  @override
  @JsonKey(name: 'vehicle_brand')
  final String? vehicleBrand;
  @override
  @JsonKey(name: 'vehicle_model')
  final String? vehicleModel;
  @override
  @JsonKey(name: 'vehicle_year')
  final int? vehicleYear;
  @override
  @JsonKey(name: 'vehicle_engine')
  final String? vehicleEngine;
// Type de pièce recherchée
  @override
  @JsonKey(name: 'part_type')
  final String partType;
  final List<String> _partNames;
  @override
  @JsonKey(name: 'part_names')
  List<String> get partNames {
    if (_partNames is EqualUnmodifiableListView) return _partNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_partNames);
  }

  @override
  @JsonKey(name: 'additional_info')
  final String? additionalInfo;
// Métadonnées
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'is_anonymous')
  final bool isAnonymous;
  @override
  @JsonKey(name: 'response_count')
  final int responseCount;
  @override
  @JsonKey(name: 'pending_response_count')
  final int pendingResponseCount;
// Timestamps
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;

  @override
  String toString() {
    return 'PartRequestModel(id: $id, userId: $userId, vehiclePlate: $vehiclePlate, vehicleBrand: $vehicleBrand, vehicleModel: $vehicleModel, vehicleYear: $vehicleYear, vehicleEngine: $vehicleEngine, partType: $partType, partNames: $partNames, additionalInfo: $additionalInfo, status: $status, isAnonymous: $isAnonymous, responseCount: $responseCount, pendingResponseCount: $pendingResponseCount, createdAt: $createdAt, updatedAt: $updatedAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartRequestModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.vehiclePlate, vehiclePlate) ||
                other.vehiclePlate == vehiclePlate) &&
            (identical(other.vehicleBrand, vehicleBrand) ||
                other.vehicleBrand == vehicleBrand) &&
            (identical(other.vehicleModel, vehicleModel) ||
                other.vehicleModel == vehicleModel) &&
            (identical(other.vehicleYear, vehicleYear) ||
                other.vehicleYear == vehicleYear) &&
            (identical(other.vehicleEngine, vehicleEngine) ||
                other.vehicleEngine == vehicleEngine) &&
            (identical(other.partType, partType) ||
                other.partType == partType) &&
            const DeepCollectionEquality()
                .equals(other._partNames, _partNames) &&
            (identical(other.additionalInfo, additionalInfo) ||
                other.additionalInfo == additionalInfo) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isAnonymous, isAnonymous) ||
                other.isAnonymous == isAnonymous) &&
            (identical(other.responseCount, responseCount) ||
                other.responseCount == responseCount) &&
            (identical(other.pendingResponseCount, pendingResponseCount) ||
                other.pendingResponseCount == pendingResponseCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      vehiclePlate,
      vehicleBrand,
      vehicleModel,
      vehicleYear,
      vehicleEngine,
      partType,
      const DeepCollectionEquality().hash(_partNames),
      additionalInfo,
      status,
      isAnonymous,
      responseCount,
      pendingResponseCount,
      createdAt,
      updatedAt,
      expiresAt);

  /// Create a copy of PartRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PartRequestModelImplCopyWith<_$PartRequestModelImpl> get copyWith =>
      __$$PartRequestModelImplCopyWithImpl<_$PartRequestModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PartRequestModelImplToJson(
      this,
    );
  }
}

abstract class _PartRequestModel extends PartRequestModel {
  const factory _PartRequestModel(
      {required final String id,
      @JsonKey(name: 'user_id') final String? userId,
      @JsonKey(name: 'vehicle_plate') final String? vehiclePlate,
      @JsonKey(name: 'vehicle_brand') final String? vehicleBrand,
      @JsonKey(name: 'vehicle_model') final String? vehicleModel,
      @JsonKey(name: 'vehicle_year') final int? vehicleYear,
      @JsonKey(name: 'vehicle_engine') final String? vehicleEngine,
      @JsonKey(name: 'part_type') required final String partType,
      @JsonKey(name: 'part_names') required final List<String> partNames,
      @JsonKey(name: 'additional_info') final String? additionalInfo,
      final String status,
      @JsonKey(name: 'is_anonymous') final bool isAnonymous,
      @JsonKey(name: 'response_count') final int responseCount,
      @JsonKey(name: 'pending_response_count') final int pendingResponseCount,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      @JsonKey(name: 'expires_at')
      final DateTime? expiresAt}) = _$PartRequestModelImpl;
  const _PartRequestModel._() : super._();

  factory _PartRequestModel.fromJson(Map<String, dynamic> json) =
      _$PartRequestModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String? get userId; // Informations du véhicule
  @override
  @JsonKey(name: 'vehicle_plate')
  String? get vehiclePlate;
  @override
  @JsonKey(name: 'vehicle_brand')
  String? get vehicleBrand;
  @override
  @JsonKey(name: 'vehicle_model')
  String? get vehicleModel;
  @override
  @JsonKey(name: 'vehicle_year')
  int? get vehicleYear;
  @override
  @JsonKey(name: 'vehicle_engine')
  String? get vehicleEngine; // Type de pièce recherchée
  @override
  @JsonKey(name: 'part_type')
  String get partType;
  @override
  @JsonKey(name: 'part_names')
  List<String> get partNames;
  @override
  @JsonKey(name: 'additional_info')
  String? get additionalInfo; // Métadonnées
  @override
  String get status;
  @override
  @JsonKey(name: 'is_anonymous')
  bool get isAnonymous;
  @override
  @JsonKey(name: 'response_count')
  int get responseCount;
  @override
  @JsonKey(name: 'pending_response_count')
  int get pendingResponseCount; // Timestamps
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt;

  /// Create a copy of PartRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PartRequestModelImplCopyWith<_$PartRequestModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

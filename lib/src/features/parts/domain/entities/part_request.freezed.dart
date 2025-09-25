// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'part_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PartRequest {
  String get id => throw _privateConstructorUsedError;
  String? get userId =>
      throw _privateConstructorUsedError; // Informations du véhicule
  String? get vehiclePlate => throw _privateConstructorUsedError;
  String? get vehicleBrand => throw _privateConstructorUsedError;
  String? get vehicleModel => throw _privateConstructorUsedError;
  int? get vehicleYear => throw _privateConstructorUsedError;
  String? get vehicleEngine =>
      throw _privateConstructorUsedError; // Type de pièce recherchée
  String get partType =>
      throw _privateConstructorUsedError; // 'engine' ou 'body'
  List<String> get partNames => throw _privateConstructorUsedError;
  String? get additionalInfo =>
      throw _privateConstructorUsedError; // Métadonnées
  String get status =>
      throw _privateConstructorUsedError; // 'active', 'closed', 'fulfilled'
  bool get isAnonymous => throw _privateConstructorUsedError;
  bool get isSellerRequest =>
      throw _privateConstructorUsedError; // Indique si la demande vient d'un vendeur
  int get responseCount => throw _privateConstructorUsedError;
  int get pendingResponseCount =>
      throw _privateConstructorUsedError; // Timestamps
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  /// Create a copy of PartRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PartRequestCopyWith<PartRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartRequestCopyWith<$Res> {
  factory $PartRequestCopyWith(
          PartRequest value, $Res Function(PartRequest) then) =
      _$PartRequestCopyWithImpl<$Res, PartRequest>;
  @useResult
  $Res call(
      {String id,
      String? userId,
      String? vehiclePlate,
      String? vehicleBrand,
      String? vehicleModel,
      int? vehicleYear,
      String? vehicleEngine,
      String partType,
      List<String> partNames,
      String? additionalInfo,
      String status,
      bool isAnonymous,
      bool isSellerRequest,
      int responseCount,
      int pendingResponseCount,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? expiresAt});
}

/// @nodoc
class _$PartRequestCopyWithImpl<$Res, $Val extends PartRequest>
    implements $PartRequestCopyWith<$Res> {
  _$PartRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PartRequest
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
    Object? isSellerRequest = null,
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
      isSellerRequest: null == isSellerRequest
          ? _value.isSellerRequest
          : isSellerRequest // ignore: cast_nullable_to_non_nullable
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
abstract class _$$PartRequestImplCopyWith<$Res>
    implements $PartRequestCopyWith<$Res> {
  factory _$$PartRequestImplCopyWith(
          _$PartRequestImpl value, $Res Function(_$PartRequestImpl) then) =
      __$$PartRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? userId,
      String? vehiclePlate,
      String? vehicleBrand,
      String? vehicleModel,
      int? vehicleYear,
      String? vehicleEngine,
      String partType,
      List<String> partNames,
      String? additionalInfo,
      String status,
      bool isAnonymous,
      bool isSellerRequest,
      int responseCount,
      int pendingResponseCount,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? expiresAt});
}

/// @nodoc
class __$$PartRequestImplCopyWithImpl<$Res>
    extends _$PartRequestCopyWithImpl<$Res, _$PartRequestImpl>
    implements _$$PartRequestImplCopyWith<$Res> {
  __$$PartRequestImplCopyWithImpl(
      _$PartRequestImpl _value, $Res Function(_$PartRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of PartRequest
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
    Object? isSellerRequest = null,
    Object? responseCount = null,
    Object? pendingResponseCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_$PartRequestImpl(
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
      isSellerRequest: null == isSellerRequest
          ? _value.isSellerRequest
          : isSellerRequest // ignore: cast_nullable_to_non_nullable
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

class _$PartRequestImpl extends _PartRequest {
  const _$PartRequestImpl(
      {required this.id,
      this.userId,
      this.vehiclePlate,
      this.vehicleBrand,
      this.vehicleModel,
      this.vehicleYear,
      this.vehicleEngine,
      required this.partType,
      required final List<String> partNames,
      this.additionalInfo,
      this.status = 'active',
      this.isAnonymous = false,
      this.isSellerRequest = false,
      this.responseCount = 0,
      this.pendingResponseCount = 0,
      required this.createdAt,
      required this.updatedAt,
      this.expiresAt})
      : _partNames = partNames,
        super._();

  @override
  final String id;
  @override
  final String? userId;
// Informations du véhicule
  @override
  final String? vehiclePlate;
  @override
  final String? vehicleBrand;
  @override
  final String? vehicleModel;
  @override
  final int? vehicleYear;
  @override
  final String? vehicleEngine;
// Type de pièce recherchée
  @override
  final String partType;
// 'engine' ou 'body'
  final List<String> _partNames;
// 'engine' ou 'body'
  @override
  List<String> get partNames {
    if (_partNames is EqualUnmodifiableListView) return _partNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_partNames);
  }

  @override
  final String? additionalInfo;
// Métadonnées
  @override
  @JsonKey()
  final String status;
// 'active', 'closed', 'fulfilled'
  @override
  @JsonKey()
  final bool isAnonymous;
  @override
  @JsonKey()
  final bool isSellerRequest;
// Indique si la demande vient d'un vendeur
  @override
  @JsonKey()
  final int responseCount;
  @override
  @JsonKey()
  final int pendingResponseCount;
// Timestamps
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? expiresAt;

  @override
  String toString() {
    return 'PartRequest(id: $id, userId: $userId, vehiclePlate: $vehiclePlate, vehicleBrand: $vehicleBrand, vehicleModel: $vehicleModel, vehicleYear: $vehicleYear, vehicleEngine: $vehicleEngine, partType: $partType, partNames: $partNames, additionalInfo: $additionalInfo, status: $status, isAnonymous: $isAnonymous, isSellerRequest: $isSellerRequest, responseCount: $responseCount, pendingResponseCount: $pendingResponseCount, createdAt: $createdAt, updatedAt: $updatedAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartRequestImpl &&
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
            (identical(other.isSellerRequest, isSellerRequest) ||
                other.isSellerRequest == isSellerRequest) &&
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
      isSellerRequest,
      responseCount,
      pendingResponseCount,
      createdAt,
      updatedAt,
      expiresAt);

  /// Create a copy of PartRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PartRequestImplCopyWith<_$PartRequestImpl> get copyWith =>
      __$$PartRequestImplCopyWithImpl<_$PartRequestImpl>(this, _$identity);
}

abstract class _PartRequest extends PartRequest {
  const factory _PartRequest(
      {required final String id,
      final String? userId,
      final String? vehiclePlate,
      final String? vehicleBrand,
      final String? vehicleModel,
      final int? vehicleYear,
      final String? vehicleEngine,
      required final String partType,
      required final List<String> partNames,
      final String? additionalInfo,
      final String status,
      final bool isAnonymous,
      final bool isSellerRequest,
      final int responseCount,
      final int pendingResponseCount,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final DateTime? expiresAt}) = _$PartRequestImpl;
  const _PartRequest._() : super._();

  @override
  String get id;
  @override
  String? get userId; // Informations du véhicule
  @override
  String? get vehiclePlate;
  @override
  String? get vehicleBrand;
  @override
  String? get vehicleModel;
  @override
  int? get vehicleYear;
  @override
  String? get vehicleEngine; // Type de pièce recherchée
  @override
  String get partType; // 'engine' ou 'body'
  @override
  List<String> get partNames;
  @override
  String? get additionalInfo; // Métadonnées
  @override
  String get status; // 'active', 'closed', 'fulfilled'
  @override
  bool get isAnonymous;
  @override
  bool get isSellerRequest; // Indique si la demande vient d'un vendeur
  @override
  int get responseCount;
  @override
  int get pendingResponseCount; // Timestamps
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get expiresAt;

  /// Create a copy of PartRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PartRequestImplCopyWith<_$PartRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CreatePartRequestParams {
// Informations du véhicule
  String? get vehiclePlate => throw _privateConstructorUsedError;
  String? get vehicleBrand => throw _privateConstructorUsedError;
  String? get vehicleModel => throw _privateConstructorUsedError;
  int? get vehicleYear => throw _privateConstructorUsedError;
  String? get vehicleEngine =>
      throw _privateConstructorUsedError; // Type de pièce recherchée
  String get partType => throw _privateConstructorUsedError;
  List<String> get partNames => throw _privateConstructorUsedError;
  String? get additionalInfo =>
      throw _privateConstructorUsedError; // Métadonnées
  bool get isAnonymous => throw _privateConstructorUsedError;
  bool get isSellerRequest => throw _privateConstructorUsedError;

  /// Create a copy of CreatePartRequestParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreatePartRequestParamsCopyWith<CreatePartRequestParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreatePartRequestParamsCopyWith<$Res> {
  factory $CreatePartRequestParamsCopyWith(CreatePartRequestParams value,
          $Res Function(CreatePartRequestParams) then) =
      _$CreatePartRequestParamsCopyWithImpl<$Res, CreatePartRequestParams>;
  @useResult
  $Res call(
      {String? vehiclePlate,
      String? vehicleBrand,
      String? vehicleModel,
      int? vehicleYear,
      String? vehicleEngine,
      String partType,
      List<String> partNames,
      String? additionalInfo,
      bool isAnonymous,
      bool isSellerRequest});
}

/// @nodoc
class _$CreatePartRequestParamsCopyWithImpl<$Res,
        $Val extends CreatePartRequestParams>
    implements $CreatePartRequestParamsCopyWith<$Res> {
  _$CreatePartRequestParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreatePartRequestParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vehiclePlate = freezed,
    Object? vehicleBrand = freezed,
    Object? vehicleModel = freezed,
    Object? vehicleYear = freezed,
    Object? vehicleEngine = freezed,
    Object? partType = null,
    Object? partNames = null,
    Object? additionalInfo = freezed,
    Object? isAnonymous = null,
    Object? isSellerRequest = null,
  }) {
    return _then(_value.copyWith(
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
      isAnonymous: null == isAnonymous
          ? _value.isAnonymous
          : isAnonymous // ignore: cast_nullable_to_non_nullable
              as bool,
      isSellerRequest: null == isSellerRequest
          ? _value.isSellerRequest
          : isSellerRequest // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreatePartRequestParamsImplCopyWith<$Res>
    implements $CreatePartRequestParamsCopyWith<$Res> {
  factory _$$CreatePartRequestParamsImplCopyWith(
          _$CreatePartRequestParamsImpl value,
          $Res Function(_$CreatePartRequestParamsImpl) then) =
      __$$CreatePartRequestParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? vehiclePlate,
      String? vehicleBrand,
      String? vehicleModel,
      int? vehicleYear,
      String? vehicleEngine,
      String partType,
      List<String> partNames,
      String? additionalInfo,
      bool isAnonymous,
      bool isSellerRequest});
}

/// @nodoc
class __$$CreatePartRequestParamsImplCopyWithImpl<$Res>
    extends _$CreatePartRequestParamsCopyWithImpl<$Res,
        _$CreatePartRequestParamsImpl>
    implements _$$CreatePartRequestParamsImplCopyWith<$Res> {
  __$$CreatePartRequestParamsImplCopyWithImpl(
      _$CreatePartRequestParamsImpl _value,
      $Res Function(_$CreatePartRequestParamsImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreatePartRequestParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vehiclePlate = freezed,
    Object? vehicleBrand = freezed,
    Object? vehicleModel = freezed,
    Object? vehicleYear = freezed,
    Object? vehicleEngine = freezed,
    Object? partType = null,
    Object? partNames = null,
    Object? additionalInfo = freezed,
    Object? isAnonymous = null,
    Object? isSellerRequest = null,
  }) {
    return _then(_$CreatePartRequestParamsImpl(
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
      isAnonymous: null == isAnonymous
          ? _value.isAnonymous
          : isAnonymous // ignore: cast_nullable_to_non_nullable
              as bool,
      isSellerRequest: null == isSellerRequest
          ? _value.isSellerRequest
          : isSellerRequest // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$CreatePartRequestParamsImpl implements _CreatePartRequestParams {
  const _$CreatePartRequestParamsImpl(
      {this.vehiclePlate,
      this.vehicleBrand,
      this.vehicleModel,
      this.vehicleYear,
      this.vehicleEngine,
      required this.partType,
      required final List<String> partNames,
      this.additionalInfo,
      this.isAnonymous = false,
      this.isSellerRequest = false})
      : _partNames = partNames;

// Informations du véhicule
  @override
  final String? vehiclePlate;
  @override
  final String? vehicleBrand;
  @override
  final String? vehicleModel;
  @override
  final int? vehicleYear;
  @override
  final String? vehicleEngine;
// Type de pièce recherchée
  @override
  final String partType;
  final List<String> _partNames;
  @override
  List<String> get partNames {
    if (_partNames is EqualUnmodifiableListView) return _partNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_partNames);
  }

  @override
  final String? additionalInfo;
// Métadonnées
  @override
  @JsonKey()
  final bool isAnonymous;
  @override
  @JsonKey()
  final bool isSellerRequest;

  @override
  String toString() {
    return 'CreatePartRequestParams(vehiclePlate: $vehiclePlate, vehicleBrand: $vehicleBrand, vehicleModel: $vehicleModel, vehicleYear: $vehicleYear, vehicleEngine: $vehicleEngine, partType: $partType, partNames: $partNames, additionalInfo: $additionalInfo, isAnonymous: $isAnonymous, isSellerRequest: $isSellerRequest)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreatePartRequestParamsImpl &&
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
            (identical(other.isAnonymous, isAnonymous) ||
                other.isAnonymous == isAnonymous) &&
            (identical(other.isSellerRequest, isSellerRequest) ||
                other.isSellerRequest == isSellerRequest));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      vehiclePlate,
      vehicleBrand,
      vehicleModel,
      vehicleYear,
      vehicleEngine,
      partType,
      const DeepCollectionEquality().hash(_partNames),
      additionalInfo,
      isAnonymous,
      isSellerRequest);

  /// Create a copy of CreatePartRequestParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreatePartRequestParamsImplCopyWith<_$CreatePartRequestParamsImpl>
      get copyWith => __$$CreatePartRequestParamsImplCopyWithImpl<
          _$CreatePartRequestParamsImpl>(this, _$identity);
}

abstract class _CreatePartRequestParams implements CreatePartRequestParams {
  const factory _CreatePartRequestParams(
      {final String? vehiclePlate,
      final String? vehicleBrand,
      final String? vehicleModel,
      final int? vehicleYear,
      final String? vehicleEngine,
      required final String partType,
      required final List<String> partNames,
      final String? additionalInfo,
      final bool isAnonymous,
      final bool isSellerRequest}) = _$CreatePartRequestParamsImpl;

// Informations du véhicule
  @override
  String? get vehiclePlate;
  @override
  String? get vehicleBrand;
  @override
  String? get vehicleModel;
  @override
  int? get vehicleYear;
  @override
  String? get vehicleEngine; // Type de pièce recherchée
  @override
  String get partType;
  @override
  List<String> get partNames;
  @override
  String? get additionalInfo; // Métadonnées
  @override
  bool get isAnonymous;
  @override
  bool get isSellerRequest;

  /// Create a copy of CreatePartRequestParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreatePartRequestParamsImplCopyWith<_$CreatePartRequestParamsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

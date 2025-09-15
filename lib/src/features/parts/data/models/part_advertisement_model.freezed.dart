// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'part_advertisement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PartAdvertisementModel _$PartAdvertisementModelFromJson(
    Map<String, dynamic> json) {
  return _PartAdvertisementModel.fromJson(json);
}

/// @nodoc
mixin _$PartAdvertisementModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'part_type')
  String get partType => throw _privateConstructorUsedError;
  @JsonKey(name: 'part_name')
  String get partName => throw _privateConstructorUsedError;
  @JsonKey(name: 'vehicle_plate')
  String? get vehiclePlate => throw _privateConstructorUsedError;
  @JsonKey(name: 'vehicle_brand')
  String? get vehicleBrand => throw _privateConstructorUsedError;
  @JsonKey(name: 'vehicle_model')
  String? get vehicleModel => throw _privateConstructorUsedError;
  @JsonKey(name: 'vehicle_year')
  int? get vehicleYear => throw _privateConstructorUsedError;
  @JsonKey(name: 'vehicle_engine')
  String? get vehicleEngine => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double? get price => throw _privateConstructorUsedError;
  String? get condition => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_negotiable')
  bool get isNegotiable => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_phone')
  String? get contactPhone => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_email')
  String? get contactEmail => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  @JsonKey(name: 'zip_code')
  String? get zipCode => throw _privateConstructorUsedError;
  String? get department => throw _privateConstructorUsedError;
  @JsonKey(name: 'view_count')
  int get viewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_count')
  int get contactCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PartAdvertisementModelCopyWith<PartAdvertisementModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartAdvertisementModelCopyWith<$Res> {
  factory $PartAdvertisementModelCopyWith(PartAdvertisementModel value,
          $Res Function(PartAdvertisementModel) then) =
      _$PartAdvertisementModelCopyWithImpl<$Res, PartAdvertisementModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'part_type') String partType,
      @JsonKey(name: 'part_name') String partName,
      @JsonKey(name: 'vehicle_plate') String? vehiclePlate,
      @JsonKey(name: 'vehicle_brand') String? vehicleBrand,
      @JsonKey(name: 'vehicle_model') String? vehicleModel,
      @JsonKey(name: 'vehicle_year') int? vehicleYear,
      @JsonKey(name: 'vehicle_engine') String? vehicleEngine,
      String? description,
      double? price,
      String? condition,
      List<String> images,
      String status,
      @JsonKey(name: 'is_negotiable') bool isNegotiable,
      @JsonKey(name: 'contact_phone') String? contactPhone,
      @JsonKey(name: 'contact_email') String? contactEmail,
      String? city,
      @JsonKey(name: 'zip_code') String? zipCode,
      String? department,
      @JsonKey(name: 'view_count') int viewCount,
      @JsonKey(name: 'contact_count') int contactCount,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'expires_at') DateTime? expiresAt});
}

/// @nodoc
class _$PartAdvertisementModelCopyWithImpl<$Res,
        $Val extends PartAdvertisementModel>
    implements $PartAdvertisementModelCopyWith<$Res> {
  _$PartAdvertisementModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? partType = null,
    Object? partName = null,
    Object? vehiclePlate = freezed,
    Object? vehicleBrand = freezed,
    Object? vehicleModel = freezed,
    Object? vehicleYear = freezed,
    Object? vehicleEngine = freezed,
    Object? description = freezed,
    Object? price = freezed,
    Object? condition = freezed,
    Object? images = null,
    Object? status = null,
    Object? isNegotiable = null,
    Object? contactPhone = freezed,
    Object? contactEmail = freezed,
    Object? city = freezed,
    Object? zipCode = freezed,
    Object? department = freezed,
    Object? viewCount = null,
    Object? contactCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      partType: null == partType
          ? _value.partType
          : partType // ignore: cast_nullable_to_non_nullable
              as String,
      partName: null == partName
          ? _value.partName
          : partName // ignore: cast_nullable_to_non_nullable
              as String,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      condition: freezed == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String?,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isNegotiable: null == isNegotiable
          ? _value.isNegotiable
          : isNegotiable // ignore: cast_nullable_to_non_nullable
              as bool,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      zipCode: freezed == zipCode
          ? _value.zipCode
          : zipCode // ignore: cast_nullable_to_non_nullable
              as String?,
      department: freezed == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      contactCount: null == contactCount
          ? _value.contactCount
          : contactCount // ignore: cast_nullable_to_non_nullable
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
abstract class _$$PartAdvertisementModelImplCopyWith<$Res>
    implements $PartAdvertisementModelCopyWith<$Res> {
  factory _$$PartAdvertisementModelImplCopyWith(
          _$PartAdvertisementModelImpl value,
          $Res Function(_$PartAdvertisementModelImpl) then) =
      __$$PartAdvertisementModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'part_type') String partType,
      @JsonKey(name: 'part_name') String partName,
      @JsonKey(name: 'vehicle_plate') String? vehiclePlate,
      @JsonKey(name: 'vehicle_brand') String? vehicleBrand,
      @JsonKey(name: 'vehicle_model') String? vehicleModel,
      @JsonKey(name: 'vehicle_year') int? vehicleYear,
      @JsonKey(name: 'vehicle_engine') String? vehicleEngine,
      String? description,
      double? price,
      String? condition,
      List<String> images,
      String status,
      @JsonKey(name: 'is_negotiable') bool isNegotiable,
      @JsonKey(name: 'contact_phone') String? contactPhone,
      @JsonKey(name: 'contact_email') String? contactEmail,
      String? city,
      @JsonKey(name: 'zip_code') String? zipCode,
      String? department,
      @JsonKey(name: 'view_count') int viewCount,
      @JsonKey(name: 'contact_count') int contactCount,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'expires_at') DateTime? expiresAt});
}

/// @nodoc
class __$$PartAdvertisementModelImplCopyWithImpl<$Res>
    extends _$PartAdvertisementModelCopyWithImpl<$Res,
        _$PartAdvertisementModelImpl>
    implements _$$PartAdvertisementModelImplCopyWith<$Res> {
  __$$PartAdvertisementModelImplCopyWithImpl(
      _$PartAdvertisementModelImpl _value,
      $Res Function(_$PartAdvertisementModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? partType = null,
    Object? partName = null,
    Object? vehiclePlate = freezed,
    Object? vehicleBrand = freezed,
    Object? vehicleModel = freezed,
    Object? vehicleYear = freezed,
    Object? vehicleEngine = freezed,
    Object? description = freezed,
    Object? price = freezed,
    Object? condition = freezed,
    Object? images = null,
    Object? status = null,
    Object? isNegotiable = null,
    Object? contactPhone = freezed,
    Object? contactEmail = freezed,
    Object? city = freezed,
    Object? zipCode = freezed,
    Object? department = freezed,
    Object? viewCount = null,
    Object? contactCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_$PartAdvertisementModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      partType: null == partType
          ? _value.partType
          : partType // ignore: cast_nullable_to_non_nullable
              as String,
      partName: null == partName
          ? _value.partName
          : partName // ignore: cast_nullable_to_non_nullable
              as String,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      condition: freezed == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String?,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isNegotiable: null == isNegotiable
          ? _value.isNegotiable
          : isNegotiable // ignore: cast_nullable_to_non_nullable
              as bool,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      zipCode: freezed == zipCode
          ? _value.zipCode
          : zipCode // ignore: cast_nullable_to_non_nullable
              as String?,
      department: freezed == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      contactCount: null == contactCount
          ? _value.contactCount
          : contactCount // ignore: cast_nullable_to_non_nullable
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
class _$PartAdvertisementModelImpl extends _PartAdvertisementModel {
  const _$PartAdvertisementModelImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'part_type') required this.partType,
      @JsonKey(name: 'part_name') required this.partName,
      @JsonKey(name: 'vehicle_plate') this.vehiclePlate,
      @JsonKey(name: 'vehicle_brand') this.vehicleBrand,
      @JsonKey(name: 'vehicle_model') this.vehicleModel,
      @JsonKey(name: 'vehicle_year') this.vehicleYear,
      @JsonKey(name: 'vehicle_engine') this.vehicleEngine,
      this.description,
      this.price,
      this.condition,
      final List<String> images = const [],
      this.status = 'active',
      @JsonKey(name: 'is_negotiable') this.isNegotiable = true,
      @JsonKey(name: 'contact_phone') this.contactPhone,
      @JsonKey(name: 'contact_email') this.contactEmail,
      this.city,
      @JsonKey(name: 'zip_code') this.zipCode,
      this.department,
      @JsonKey(name: 'view_count') this.viewCount = 0,
      @JsonKey(name: 'contact_count') this.contactCount = 0,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'expires_at') this.expiresAt})
      : _images = images,
        super._();

  factory _$PartAdvertisementModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PartAdvertisementModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'part_type')
  final String partType;
  @override
  @JsonKey(name: 'part_name')
  final String partName;
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
  @override
  final String? description;
  @override
  final double? price;
  @override
  final String? condition;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'is_negotiable')
  final bool isNegotiable;
  @override
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;
  @override
  @JsonKey(name: 'contact_email')
  final String? contactEmail;
  @override
  final String? city;
  @override
  @JsonKey(name: 'zip_code')
  final String? zipCode;
  @override
  final String? department;
  @override
  @JsonKey(name: 'view_count')
  final int viewCount;
  @override
  @JsonKey(name: 'contact_count')
  final int contactCount;
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
    return 'PartAdvertisementModel(id: $id, userId: $userId, partType: $partType, partName: $partName, vehiclePlate: $vehiclePlate, vehicleBrand: $vehicleBrand, vehicleModel: $vehicleModel, vehicleYear: $vehicleYear, vehicleEngine: $vehicleEngine, description: $description, price: $price, condition: $condition, images: $images, status: $status, isNegotiable: $isNegotiable, contactPhone: $contactPhone, contactEmail: $contactEmail, city: $city, zipCode: $zipCode, department: $department, viewCount: $viewCount, contactCount: $contactCount, createdAt: $createdAt, updatedAt: $updatedAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartAdvertisementModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.partType, partType) ||
                other.partType == partType) &&
            (identical(other.partName, partName) ||
                other.partName == partName) &&
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
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isNegotiable, isNegotiable) ||
                other.isNegotiable == isNegotiable) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.zipCode, zipCode) || other.zipCode == zipCode) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.contactCount, contactCount) ||
                other.contactCount == contactCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        partType,
        partName,
        vehiclePlate,
        vehicleBrand,
        vehicleModel,
        vehicleYear,
        vehicleEngine,
        description,
        price,
        condition,
        const DeepCollectionEquality().hash(_images),
        status,
        isNegotiable,
        contactPhone,
        contactEmail,
        city,
        zipCode,
        department,
        viewCount,
        contactCount,
        createdAt,
        updatedAt,
        expiresAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PartAdvertisementModelImplCopyWith<_$PartAdvertisementModelImpl>
      get copyWith => __$$PartAdvertisementModelImplCopyWithImpl<
          _$PartAdvertisementModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PartAdvertisementModelImplToJson(
      this,
    );
  }
}

abstract class _PartAdvertisementModel extends PartAdvertisementModel {
  const factory _PartAdvertisementModel(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          @JsonKey(name: 'part_type') required final String partType,
          @JsonKey(name: 'part_name') required final String partName,
          @JsonKey(name: 'vehicle_plate') final String? vehiclePlate,
          @JsonKey(name: 'vehicle_brand') final String? vehicleBrand,
          @JsonKey(name: 'vehicle_model') final String? vehicleModel,
          @JsonKey(name: 'vehicle_year') final int? vehicleYear,
          @JsonKey(name: 'vehicle_engine') final String? vehicleEngine,
          final String? description,
          final double? price,
          final String? condition,
          final List<String> images,
          final String status,
          @JsonKey(name: 'is_negotiable') final bool isNegotiable,
          @JsonKey(name: 'contact_phone') final String? contactPhone,
          @JsonKey(name: 'contact_email') final String? contactEmail,
          final String? city,
          @JsonKey(name: 'zip_code') final String? zipCode,
          final String? department,
          @JsonKey(name: 'view_count') final int viewCount,
          @JsonKey(name: 'contact_count') final int contactCount,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt,
          @JsonKey(name: 'expires_at') final DateTime? expiresAt}) =
      _$PartAdvertisementModelImpl;
  const _PartAdvertisementModel._() : super._();

  factory _PartAdvertisementModel.fromJson(Map<String, dynamic> json) =
      _$PartAdvertisementModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'part_type')
  String get partType;
  @override
  @JsonKey(name: 'part_name')
  String get partName;
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
  String? get vehicleEngine;
  @override
  String? get description;
  @override
  double? get price;
  @override
  String? get condition;
  @override
  List<String> get images;
  @override
  String get status;
  @override
  @JsonKey(name: 'is_negotiable')
  bool get isNegotiable;
  @override
  @JsonKey(name: 'contact_phone')
  String? get contactPhone;
  @override
  @JsonKey(name: 'contact_email')
  String? get contactEmail;
  @override
  String? get city;
  @override
  @JsonKey(name: 'zip_code')
  String? get zipCode;
  @override
  String? get department;
  @override
  @JsonKey(name: 'view_count')
  int get viewCount;
  @override
  @JsonKey(name: 'contact_count')
  int get contactCount;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt;
  @override
  @JsonKey(ignore: true)
  _$$PartAdvertisementModelImplCopyWith<_$PartAdvertisementModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CreatePartAdvertisementParams _$CreatePartAdvertisementParamsFromJson(
    Map<String, dynamic> json) {
  return _CreatePartAdvertisementParams.fromJson(json);
}

/// @nodoc
mixin _$CreatePartAdvertisementParams {
  String get partType =>
      throw _privateConstructorUsedError; // 'engine' ou 'body' depuis le front
  String get partName => throw _privateConstructorUsedError;
  String? get vehiclePlate => throw _privateConstructorUsedError;
  String? get vehicleBrand => throw _privateConstructorUsedError;
  String? get vehicleModel => throw _privateConstructorUsedError;
  int? get vehicleYear => throw _privateConstructorUsedError;
  String? get vehicleEngine => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double? get price => throw _privateConstructorUsedError;
  String? get condition => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  String? get contactPhone => throw _privateConstructorUsedError;
  String? get contactEmail => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreatePartAdvertisementParamsCopyWith<CreatePartAdvertisementParams>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreatePartAdvertisementParamsCopyWith<$Res> {
  factory $CreatePartAdvertisementParamsCopyWith(
          CreatePartAdvertisementParams value,
          $Res Function(CreatePartAdvertisementParams) then) =
      _$CreatePartAdvertisementParamsCopyWithImpl<$Res,
          CreatePartAdvertisementParams>;
  @useResult
  $Res call(
      {String partType,
      String partName,
      String? vehiclePlate,
      String? vehicleBrand,
      String? vehicleModel,
      int? vehicleYear,
      String? vehicleEngine,
      String? description,
      double? price,
      String? condition,
      List<String> images,
      String? contactPhone,
      String? contactEmail});
}

/// @nodoc
class _$CreatePartAdvertisementParamsCopyWithImpl<$Res,
        $Val extends CreatePartAdvertisementParams>
    implements $CreatePartAdvertisementParamsCopyWith<$Res> {
  _$CreatePartAdvertisementParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? partType = null,
    Object? partName = null,
    Object? vehiclePlate = freezed,
    Object? vehicleBrand = freezed,
    Object? vehicleModel = freezed,
    Object? vehicleYear = freezed,
    Object? vehicleEngine = freezed,
    Object? description = freezed,
    Object? price = freezed,
    Object? condition = freezed,
    Object? images = null,
    Object? contactPhone = freezed,
    Object? contactEmail = freezed,
  }) {
    return _then(_value.copyWith(
      partType: null == partType
          ? _value.partType
          : partType // ignore: cast_nullable_to_non_nullable
              as String,
      partName: null == partName
          ? _value.partName
          : partName // ignore: cast_nullable_to_non_nullable
              as String,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      condition: freezed == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String?,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreatePartAdvertisementParamsImplCopyWith<$Res>
    implements $CreatePartAdvertisementParamsCopyWith<$Res> {
  factory _$$CreatePartAdvertisementParamsImplCopyWith(
          _$CreatePartAdvertisementParamsImpl value,
          $Res Function(_$CreatePartAdvertisementParamsImpl) then) =
      __$$CreatePartAdvertisementParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String partType,
      String partName,
      String? vehiclePlate,
      String? vehicleBrand,
      String? vehicleModel,
      int? vehicleYear,
      String? vehicleEngine,
      String? description,
      double? price,
      String? condition,
      List<String> images,
      String? contactPhone,
      String? contactEmail});
}

/// @nodoc
class __$$CreatePartAdvertisementParamsImplCopyWithImpl<$Res>
    extends _$CreatePartAdvertisementParamsCopyWithImpl<$Res,
        _$CreatePartAdvertisementParamsImpl>
    implements _$$CreatePartAdvertisementParamsImplCopyWith<$Res> {
  __$$CreatePartAdvertisementParamsImplCopyWithImpl(
      _$CreatePartAdvertisementParamsImpl _value,
      $Res Function(_$CreatePartAdvertisementParamsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? partType = null,
    Object? partName = null,
    Object? vehiclePlate = freezed,
    Object? vehicleBrand = freezed,
    Object? vehicleModel = freezed,
    Object? vehicleYear = freezed,
    Object? vehicleEngine = freezed,
    Object? description = freezed,
    Object? price = freezed,
    Object? condition = freezed,
    Object? images = null,
    Object? contactPhone = freezed,
    Object? contactEmail = freezed,
  }) {
    return _then(_$CreatePartAdvertisementParamsImpl(
      partType: null == partType
          ? _value.partType
          : partType // ignore: cast_nullable_to_non_nullable
              as String,
      partName: null == partName
          ? _value.partName
          : partName // ignore: cast_nullable_to_non_nullable
              as String,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      condition: freezed == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String?,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreatePartAdvertisementParamsImpl
    implements _CreatePartAdvertisementParams {
  const _$CreatePartAdvertisementParamsImpl(
      {required this.partType,
      required this.partName,
      this.vehiclePlate,
      this.vehicleBrand,
      this.vehicleModel,
      this.vehicleYear,
      this.vehicleEngine,
      this.description,
      this.price,
      this.condition,
      final List<String> images = const [],
      this.contactPhone,
      this.contactEmail})
      : _images = images;

  factory _$CreatePartAdvertisementParamsImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CreatePartAdvertisementParamsImplFromJson(json);

  @override
  final String partType;
// 'engine' ou 'body' depuis le front
  @override
  final String partName;
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
  @override
  final String? description;
  @override
  final double? price;
  @override
  final String? condition;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final String? contactPhone;
  @override
  final String? contactEmail;

  @override
  String toString() {
    return 'CreatePartAdvertisementParams(partType: $partType, partName: $partName, vehiclePlate: $vehiclePlate, vehicleBrand: $vehicleBrand, vehicleModel: $vehicleModel, vehicleYear: $vehicleYear, vehicleEngine: $vehicleEngine, description: $description, price: $price, condition: $condition, images: $images, contactPhone: $contactPhone, contactEmail: $contactEmail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreatePartAdvertisementParamsImpl &&
            (identical(other.partType, partType) ||
                other.partType == partType) &&
            (identical(other.partName, partName) ||
                other.partName == partName) &&
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
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      partType,
      partName,
      vehiclePlate,
      vehicleBrand,
      vehicleModel,
      vehicleYear,
      vehicleEngine,
      description,
      price,
      condition,
      const DeepCollectionEquality().hash(_images),
      contactPhone,
      contactEmail);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreatePartAdvertisementParamsImplCopyWith<
          _$CreatePartAdvertisementParamsImpl>
      get copyWith => __$$CreatePartAdvertisementParamsImplCopyWithImpl<
          _$CreatePartAdvertisementParamsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreatePartAdvertisementParamsImplToJson(
      this,
    );
  }
}

abstract class _CreatePartAdvertisementParams
    implements CreatePartAdvertisementParams {
  const factory _CreatePartAdvertisementParams(
      {required final String partType,
      required final String partName,
      final String? vehiclePlate,
      final String? vehicleBrand,
      final String? vehicleModel,
      final int? vehicleYear,
      final String? vehicleEngine,
      final String? description,
      final double? price,
      final String? condition,
      final List<String> images,
      final String? contactPhone,
      final String? contactEmail}) = _$CreatePartAdvertisementParamsImpl;

  factory _CreatePartAdvertisementParams.fromJson(Map<String, dynamic> json) =
      _$CreatePartAdvertisementParamsImpl.fromJson;

  @override
  String get partType;
  @override // 'engine' ou 'body' depuis le front
  String get partName;
  @override
  String? get vehiclePlate;
  @override
  String? get vehicleBrand;
  @override
  String? get vehicleModel;
  @override
  int? get vehicleYear;
  @override
  String? get vehicleEngine;
  @override
  String? get description;
  @override
  double? get price;
  @override
  String? get condition;
  @override
  List<String> get images;
  @override
  String? get contactPhone;
  @override
  String? get contactEmail;
  @override
  @JsonKey(ignore: true)
  _$$CreatePartAdvertisementParamsImplCopyWith<
          _$CreatePartAdvertisementParamsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SearchPartAdvertisementsParams _$SearchPartAdvertisementsParamsFromJson(
    Map<String, dynamic> json) {
  return _SearchPartAdvertisementsParams.fromJson(json);
}

/// @nodoc
mixin _$SearchPartAdvertisementsParams {
  String? get query => throw _privateConstructorUsedError;
  String? get partType => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  double? get minPrice => throw _privateConstructorUsedError;
  double? get maxPrice => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  int get offset => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SearchPartAdvertisementsParamsCopyWith<SearchPartAdvertisementsParams>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchPartAdvertisementsParamsCopyWith<$Res> {
  factory $SearchPartAdvertisementsParamsCopyWith(
          SearchPartAdvertisementsParams value,
          $Res Function(SearchPartAdvertisementsParams) then) =
      _$SearchPartAdvertisementsParamsCopyWithImpl<$Res,
          SearchPartAdvertisementsParams>;
  @useResult
  $Res call(
      {String? query,
      String? partType,
      String? city,
      double? minPrice,
      double? maxPrice,
      int limit,
      int offset});
}

/// @nodoc
class _$SearchPartAdvertisementsParamsCopyWithImpl<$Res,
        $Val extends SearchPartAdvertisementsParams>
    implements $SearchPartAdvertisementsParamsCopyWith<$Res> {
  _$SearchPartAdvertisementsParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = freezed,
    Object? partType = freezed,
    Object? city = freezed,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? limit = null,
    Object? offset = null,
  }) {
    return _then(_value.copyWith(
      query: freezed == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String?,
      partType: freezed == partType
          ? _value.partType
          : partType // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      offset: null == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchPartAdvertisementsParamsImplCopyWith<$Res>
    implements $SearchPartAdvertisementsParamsCopyWith<$Res> {
  factory _$$SearchPartAdvertisementsParamsImplCopyWith(
          _$SearchPartAdvertisementsParamsImpl value,
          $Res Function(_$SearchPartAdvertisementsParamsImpl) then) =
      __$$SearchPartAdvertisementsParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? query,
      String? partType,
      String? city,
      double? minPrice,
      double? maxPrice,
      int limit,
      int offset});
}

/// @nodoc
class __$$SearchPartAdvertisementsParamsImplCopyWithImpl<$Res>
    extends _$SearchPartAdvertisementsParamsCopyWithImpl<$Res,
        _$SearchPartAdvertisementsParamsImpl>
    implements _$$SearchPartAdvertisementsParamsImplCopyWith<$Res> {
  __$$SearchPartAdvertisementsParamsImplCopyWithImpl(
      _$SearchPartAdvertisementsParamsImpl _value,
      $Res Function(_$SearchPartAdvertisementsParamsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = freezed,
    Object? partType = freezed,
    Object? city = freezed,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? limit = null,
    Object? offset = null,
  }) {
    return _then(_$SearchPartAdvertisementsParamsImpl(
      query: freezed == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String?,
      partType: freezed == partType
          ? _value.partType
          : partType // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      offset: null == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchPartAdvertisementsParamsImpl
    implements _SearchPartAdvertisementsParams {
  const _$SearchPartAdvertisementsParamsImpl(
      {this.query,
      this.partType,
      this.city,
      this.minPrice,
      this.maxPrice,
      this.limit = 20,
      this.offset = 0});

  factory _$SearchPartAdvertisementsParamsImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$SearchPartAdvertisementsParamsImplFromJson(json);

  @override
  final String? query;
  @override
  final String? partType;
  @override
  final String? city;
  @override
  final double? minPrice;
  @override
  final double? maxPrice;
  @override
  @JsonKey()
  final int limit;
  @override
  @JsonKey()
  final int offset;

  @override
  String toString() {
    return 'SearchPartAdvertisementsParams(query: $query, partType: $partType, city: $city, minPrice: $minPrice, maxPrice: $maxPrice, limit: $limit, offset: $offset)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchPartAdvertisementsParamsImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.partType, partType) ||
                other.partType == partType) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.minPrice, minPrice) ||
                other.minPrice == minPrice) &&
            (identical(other.maxPrice, maxPrice) ||
                other.maxPrice == maxPrice) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.offset, offset) || other.offset == offset));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, query, partType, city, minPrice, maxPrice, limit, offset);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchPartAdvertisementsParamsImplCopyWith<
          _$SearchPartAdvertisementsParamsImpl>
      get copyWith => __$$SearchPartAdvertisementsParamsImplCopyWithImpl<
          _$SearchPartAdvertisementsParamsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchPartAdvertisementsParamsImplToJson(
      this,
    );
  }
}

abstract class _SearchPartAdvertisementsParams
    implements SearchPartAdvertisementsParams {
  const factory _SearchPartAdvertisementsParams(
      {final String? query,
      final String? partType,
      final String? city,
      final double? minPrice,
      final double? maxPrice,
      final int limit,
      final int offset}) = _$SearchPartAdvertisementsParamsImpl;

  factory _SearchPartAdvertisementsParams.fromJson(Map<String, dynamic> json) =
      _$SearchPartAdvertisementsParamsImpl.fromJson;

  @override
  String? get query;
  @override
  String? get partType;
  @override
  String? get city;
  @override
  double? get minPrice;
  @override
  double? get maxPrice;
  @override
  int get limit;
  @override
  int get offset;
  @override
  @JsonKey(ignore: true)
  _$$SearchPartAdvertisementsParamsImplCopyWith<
          _$SearchPartAdvertisementsParamsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

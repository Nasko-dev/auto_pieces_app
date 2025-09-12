// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seller_advertisement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SellerAdvertisement {
  String get id => throw _privateConstructorUsedError;
  String get sellerId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get partType => throw _privateConstructorUsedError;
  String get vehicleBrand => throw _privateConstructorUsedError;
  String get vehicleModel => throw _privateConstructorUsedError;
  int? get vehicleYear => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  AdvertisementStatus get status => throw _privateConstructorUsedError;
  List<String> get imageUrls => throw _privateConstructorUsedError;
  int get viewCount => throw _privateConstructorUsedError;
  int get messageCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get soldAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SellerAdvertisementCopyWith<SellerAdvertisement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SellerAdvertisementCopyWith<$Res> {
  factory $SellerAdvertisementCopyWith(
          SellerAdvertisement value, $Res Function(SellerAdvertisement) then) =
      _$SellerAdvertisementCopyWithImpl<$Res, SellerAdvertisement>;
  @useResult
  $Res call(
      {String id,
      String sellerId,
      String title,
      String description,
      String partType,
      String vehicleBrand,
      String vehicleModel,
      int? vehicleYear,
      double price,
      AdvertisementStatus status,
      List<String> imageUrls,
      int viewCount,
      int messageCount,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? soldAt});
}

/// @nodoc
class _$SellerAdvertisementCopyWithImpl<$Res, $Val extends SellerAdvertisement>
    implements $SellerAdvertisementCopyWith<$Res> {
  _$SellerAdvertisementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sellerId = null,
    Object? title = null,
    Object? description = null,
    Object? partType = null,
    Object? vehicleBrand = null,
    Object? vehicleModel = null,
    Object? vehicleYear = freezed,
    Object? price = null,
    Object? status = null,
    Object? imageUrls = null,
    Object? viewCount = null,
    Object? messageCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? soldAt = freezed,
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
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      partType: null == partType
          ? _value.partType
          : partType // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleBrand: null == vehicleBrand
          ? _value.vehicleBrand
          : vehicleBrand // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleModel: null == vehicleModel
          ? _value.vehicleModel
          : vehicleModel // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleYear: freezed == vehicleYear
          ? _value.vehicleYear
          : vehicleYear // ignore: cast_nullable_to_non_nullable
              as int?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AdvertisementStatus,
      imageUrls: null == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      messageCount: null == messageCount
          ? _value.messageCount
          : messageCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      soldAt: freezed == soldAt
          ? _value.soldAt
          : soldAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SellerAdvertisementImplCopyWith<$Res>
    implements $SellerAdvertisementCopyWith<$Res> {
  factory _$$SellerAdvertisementImplCopyWith(_$SellerAdvertisementImpl value,
          $Res Function(_$SellerAdvertisementImpl) then) =
      __$$SellerAdvertisementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String sellerId,
      String title,
      String description,
      String partType,
      String vehicleBrand,
      String vehicleModel,
      int? vehicleYear,
      double price,
      AdvertisementStatus status,
      List<String> imageUrls,
      int viewCount,
      int messageCount,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? soldAt});
}

/// @nodoc
class __$$SellerAdvertisementImplCopyWithImpl<$Res>
    extends _$SellerAdvertisementCopyWithImpl<$Res, _$SellerAdvertisementImpl>
    implements _$$SellerAdvertisementImplCopyWith<$Res> {
  __$$SellerAdvertisementImplCopyWithImpl(_$SellerAdvertisementImpl _value,
      $Res Function(_$SellerAdvertisementImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sellerId = null,
    Object? title = null,
    Object? description = null,
    Object? partType = null,
    Object? vehicleBrand = null,
    Object? vehicleModel = null,
    Object? vehicleYear = freezed,
    Object? price = null,
    Object? status = null,
    Object? imageUrls = null,
    Object? viewCount = null,
    Object? messageCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? soldAt = freezed,
  }) {
    return _then(_$SellerAdvertisementImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sellerId: null == sellerId
          ? _value.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      partType: null == partType
          ? _value.partType
          : partType // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleBrand: null == vehicleBrand
          ? _value.vehicleBrand
          : vehicleBrand // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleModel: null == vehicleModel
          ? _value.vehicleModel
          : vehicleModel // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleYear: freezed == vehicleYear
          ? _value.vehicleYear
          : vehicleYear // ignore: cast_nullable_to_non_nullable
              as int?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AdvertisementStatus,
      imageUrls: null == imageUrls
          ? _value._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      messageCount: null == messageCount
          ? _value.messageCount
          : messageCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      soldAt: freezed == soldAt
          ? _value.soldAt
          : soldAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$SellerAdvertisementImpl implements _SellerAdvertisement {
  const _$SellerAdvertisementImpl(
      {required this.id,
      required this.sellerId,
      required this.title,
      required this.description,
      required this.partType,
      required this.vehicleBrand,
      required this.vehicleModel,
      this.vehicleYear,
      required this.price,
      required this.status,
      required final List<String> imageUrls,
      this.viewCount = 0,
      this.messageCount = 0,
      required this.createdAt,
      required this.updatedAt,
      this.soldAt})
      : _imageUrls = imageUrls;

  @override
  final String id;
  @override
  final String sellerId;
  @override
  final String title;
  @override
  final String description;
  @override
  final String partType;
  @override
  final String vehicleBrand;
  @override
  final String vehicleModel;
  @override
  final int? vehicleYear;
  @override
  final double price;
  @override
  final AdvertisementStatus status;
  final List<String> _imageUrls;
  @override
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  @override
  @JsonKey()
  final int viewCount;
  @override
  @JsonKey()
  final int messageCount;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? soldAt;

  @override
  String toString() {
    return 'SellerAdvertisement(id: $id, sellerId: $sellerId, title: $title, description: $description, partType: $partType, vehicleBrand: $vehicleBrand, vehicleModel: $vehicleModel, vehicleYear: $vehicleYear, price: $price, status: $status, imageUrls: $imageUrls, viewCount: $viewCount, messageCount: $messageCount, createdAt: $createdAt, updatedAt: $updatedAt, soldAt: $soldAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SellerAdvertisementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sellerId, sellerId) ||
                other.sellerId == sellerId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.partType, partType) ||
                other.partType == partType) &&
            (identical(other.vehicleBrand, vehicleBrand) ||
                other.vehicleBrand == vehicleBrand) &&
            (identical(other.vehicleModel, vehicleModel) ||
                other.vehicleModel == vehicleModel) &&
            (identical(other.vehicleYear, vehicleYear) ||
                other.vehicleYear == vehicleYear) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.messageCount, messageCount) ||
                other.messageCount == messageCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.soldAt, soldAt) || other.soldAt == soldAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      sellerId,
      title,
      description,
      partType,
      vehicleBrand,
      vehicleModel,
      vehicleYear,
      price,
      status,
      const DeepCollectionEquality().hash(_imageUrls),
      viewCount,
      messageCount,
      createdAt,
      updatedAt,
      soldAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SellerAdvertisementImplCopyWith<_$SellerAdvertisementImpl> get copyWith =>
      __$$SellerAdvertisementImplCopyWithImpl<_$SellerAdvertisementImpl>(
          this, _$identity);
}

abstract class _SellerAdvertisement implements SellerAdvertisement {
  const factory _SellerAdvertisement(
      {required final String id,
      required final String sellerId,
      required final String title,
      required final String description,
      required final String partType,
      required final String vehicleBrand,
      required final String vehicleModel,
      final int? vehicleYear,
      required final double price,
      required final AdvertisementStatus status,
      required final List<String> imageUrls,
      final int viewCount,
      final int messageCount,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final DateTime? soldAt}) = _$SellerAdvertisementImpl;

  @override
  String get id;
  @override
  String get sellerId;
  @override
  String get title;
  @override
  String get description;
  @override
  String get partType;
  @override
  String get vehicleBrand;
  @override
  String get vehicleModel;
  @override
  int? get vehicleYear;
  @override
  double get price;
  @override
  AdvertisementStatus get status;
  @override
  List<String> get imageUrls;
  @override
  int get viewCount;
  @override
  int get messageCount;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get soldAt;
  @override
  @JsonKey(ignore: true)
  _$$SellerAdvertisementImplCopyWith<_$SellerAdvertisementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

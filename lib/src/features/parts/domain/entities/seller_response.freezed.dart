// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seller_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SellerResponse {
  String get id => throw _privateConstructorUsedError;
  String get requestId => throw _privateConstructorUsedError;
  String get sellerId =>
      throw _privateConstructorUsedError; // Informations du vendeur (dénormalisées pour performance)
  String? get sellerName => throw _privateConstructorUsedError;
  String? get sellerCompany => throw _privateConstructorUsedError;
  String? get sellerEmail => throw _privateConstructorUsedError;
  String? get sellerPhone =>
      throw _privateConstructorUsedError; // Détails de la réponse
  String get message => throw _privateConstructorUsedError;
  double? get price => throw _privateConstructorUsedError;
  String? get availability =>
      throw _privateConstructorUsedError; // 'available', 'order_needed', 'unavailable'
  int? get estimatedDeliveryDays =>
      throw _privateConstructorUsedError; // Pièces jointes
  List<String> get attachments =>
      throw _privateConstructorUsedError; // Status de la réponse
  String get status =>
      throw _privateConstructorUsedError; // 'pending', 'accepted', 'rejected'
// Timestamps
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SellerResponseCopyWith<SellerResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SellerResponseCopyWith<$Res> {
  factory $SellerResponseCopyWith(
          SellerResponse value, $Res Function(SellerResponse) then) =
      _$SellerResponseCopyWithImpl<$Res, SellerResponse>;
  @useResult
  $Res call(
      {String id,
      String requestId,
      String sellerId,
      String? sellerName,
      String? sellerCompany,
      String? sellerEmail,
      String? sellerPhone,
      String message,
      double? price,
      String? availability,
      int? estimatedDeliveryDays,
      List<String> attachments,
      String status,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$SellerResponseCopyWithImpl<$Res, $Val extends SellerResponse>
    implements $SellerResponseCopyWith<$Res> {
  _$SellerResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requestId = null,
    Object? sellerId = null,
    Object? sellerName = freezed,
    Object? sellerCompany = freezed,
    Object? sellerEmail = freezed,
    Object? sellerPhone = freezed,
    Object? message = null,
    Object? price = freezed,
    Object? availability = freezed,
    Object? estimatedDeliveryDays = freezed,
    Object? attachments = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      sellerId: null == sellerId
          ? _value.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String,
      sellerName: freezed == sellerName
          ? _value.sellerName
          : sellerName // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerCompany: freezed == sellerCompany
          ? _value.sellerCompany
          : sellerCompany // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerEmail: freezed == sellerEmail
          ? _value.sellerEmail
          : sellerEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerPhone: freezed == sellerPhone
          ? _value.sellerPhone
          : sellerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      availability: freezed == availability
          ? _value.availability
          : availability // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedDeliveryDays: freezed == estimatedDeliveryDays
          ? _value.estimatedDeliveryDays
          : estimatedDeliveryDays // ignore: cast_nullable_to_non_nullable
              as int?,
      attachments: null == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$SellerResponseImplCopyWith<$Res>
    implements $SellerResponseCopyWith<$Res> {
  factory _$$SellerResponseImplCopyWith(_$SellerResponseImpl value,
          $Res Function(_$SellerResponseImpl) then) =
      __$$SellerResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String requestId,
      String sellerId,
      String? sellerName,
      String? sellerCompany,
      String? sellerEmail,
      String? sellerPhone,
      String message,
      double? price,
      String? availability,
      int? estimatedDeliveryDays,
      List<String> attachments,
      String status,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$SellerResponseImplCopyWithImpl<$Res>
    extends _$SellerResponseCopyWithImpl<$Res, _$SellerResponseImpl>
    implements _$$SellerResponseImplCopyWith<$Res> {
  __$$SellerResponseImplCopyWithImpl(
      _$SellerResponseImpl _value, $Res Function(_$SellerResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requestId = null,
    Object? sellerId = null,
    Object? sellerName = freezed,
    Object? sellerCompany = freezed,
    Object? sellerEmail = freezed,
    Object? sellerPhone = freezed,
    Object? message = null,
    Object? price = freezed,
    Object? availability = freezed,
    Object? estimatedDeliveryDays = freezed,
    Object? attachments = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$SellerResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      requestId: null == requestId
          ? _value.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      sellerId: null == sellerId
          ? _value.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String,
      sellerName: freezed == sellerName
          ? _value.sellerName
          : sellerName // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerCompany: freezed == sellerCompany
          ? _value.sellerCompany
          : sellerCompany // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerEmail: freezed == sellerEmail
          ? _value.sellerEmail
          : sellerEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerPhone: freezed == sellerPhone
          ? _value.sellerPhone
          : sellerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      availability: freezed == availability
          ? _value.availability
          : availability // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedDeliveryDays: freezed == estimatedDeliveryDays
          ? _value.estimatedDeliveryDays
          : estimatedDeliveryDays // ignore: cast_nullable_to_non_nullable
              as int?,
      attachments: null == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
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

class _$SellerResponseImpl extends _SellerResponse {
  const _$SellerResponseImpl(
      {required this.id,
      required this.requestId,
      required this.sellerId,
      this.sellerName,
      this.sellerCompany,
      this.sellerEmail,
      this.sellerPhone,
      required this.message,
      this.price,
      this.availability,
      this.estimatedDeliveryDays,
      final List<String> attachments = const [],
      this.status = 'pending',
      required this.createdAt,
      required this.updatedAt})
      : _attachments = attachments,
        super._();

  @override
  final String id;
  @override
  final String requestId;
  @override
  final String sellerId;
// Informations du vendeur (dénormalisées pour performance)
  @override
  final String? sellerName;
  @override
  final String? sellerCompany;
  @override
  final String? sellerEmail;
  @override
  final String? sellerPhone;
// Détails de la réponse
  @override
  final String message;
  @override
  final double? price;
  @override
  final String? availability;
// 'available', 'order_needed', 'unavailable'
  @override
  final int? estimatedDeliveryDays;
// Pièces jointes
  final List<String> _attachments;
// Pièces jointes
  @override
  @JsonKey()
  List<String> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

// Status de la réponse
  @override
  @JsonKey()
  final String status;
// 'pending', 'accepted', 'rejected'
// Timestamps
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SellerResponse(id: $id, requestId: $requestId, sellerId: $sellerId, sellerName: $sellerName, sellerCompany: $sellerCompany, sellerEmail: $sellerEmail, sellerPhone: $sellerPhone, message: $message, price: $price, availability: $availability, estimatedDeliveryDays: $estimatedDeliveryDays, attachments: $attachments, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SellerResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.sellerId, sellerId) ||
                other.sellerId == sellerId) &&
            (identical(other.sellerName, sellerName) ||
                other.sellerName == sellerName) &&
            (identical(other.sellerCompany, sellerCompany) ||
                other.sellerCompany == sellerCompany) &&
            (identical(other.sellerEmail, sellerEmail) ||
                other.sellerEmail == sellerEmail) &&
            (identical(other.sellerPhone, sellerPhone) ||
                other.sellerPhone == sellerPhone) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.availability, availability) ||
                other.availability == availability) &&
            (identical(other.estimatedDeliveryDays, estimatedDeliveryDays) ||
                other.estimatedDeliveryDays == estimatedDeliveryDays) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      requestId,
      sellerId,
      sellerName,
      sellerCompany,
      sellerEmail,
      sellerPhone,
      message,
      price,
      availability,
      estimatedDeliveryDays,
      const DeepCollectionEquality().hash(_attachments),
      status,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SellerResponseImplCopyWith<_$SellerResponseImpl> get copyWith =>
      __$$SellerResponseImplCopyWithImpl<_$SellerResponseImpl>(
          this, _$identity);
}

abstract class _SellerResponse extends SellerResponse {
  const factory _SellerResponse(
      {required final String id,
      required final String requestId,
      required final String sellerId,
      final String? sellerName,
      final String? sellerCompany,
      final String? sellerEmail,
      final String? sellerPhone,
      required final String message,
      final double? price,
      final String? availability,
      final int? estimatedDeliveryDays,
      final List<String> attachments,
      final String status,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$SellerResponseImpl;
  const _SellerResponse._() : super._();

  @override
  String get id;
  @override
  String get requestId;
  @override
  String get sellerId;
  @override // Informations du vendeur (dénormalisées pour performance)
  String? get sellerName;
  @override
  String? get sellerCompany;
  @override
  String? get sellerEmail;
  @override
  String? get sellerPhone;
  @override // Détails de la réponse
  String get message;
  @override
  double? get price;
  @override
  String? get availability;
  @override // 'available', 'order_needed', 'unavailable'
  int? get estimatedDeliveryDays;
  @override // Pièces jointes
  List<String> get attachments;
  @override // Status de la réponse
  String get status;
  @override // 'pending', 'accepted', 'rejected'
// Timestamps
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$SellerResponseImplCopyWith<_$SellerResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

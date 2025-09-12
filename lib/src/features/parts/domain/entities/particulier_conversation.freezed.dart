// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'particulier_conversation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ParticulierConversation {
  String get id => throw _privateConstructorUsedError;
  PartRequest get partRequest => throw _privateConstructorUsedError;
  String get sellerName => throw _privateConstructorUsedError;
  String get sellerId => throw _privateConstructorUsedError;
  List<ParticulierMessage> get messages => throw _privateConstructorUsedError;
  DateTime get lastMessageAt => throw _privateConstructorUsedError;
  ConversationStatus get status => throw _privateConstructorUsedError;
  bool get hasUnreadMessages => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  double? get latestOfferPrice => throw _privateConstructorUsedError;
  int? get latestOfferDeliveryDays => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get vehiclePlate => throw _privateConstructorUsedError;
  String? get partType => throw _privateConstructorUsedError;
  List<String>? get partNames => throw _privateConstructorUsedError;
  bool? get hasNewMessages => throw _privateConstructorUsedError;

  /// Create a copy of ParticulierConversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParticulierConversationCopyWith<ParticulierConversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParticulierConversationCopyWith<$Res> {
  factory $ParticulierConversationCopyWith(ParticulierConversation value,
          $Res Function(ParticulierConversation) then) =
      _$ParticulierConversationCopyWithImpl<$Res, ParticulierConversation>;
  @useResult
  $Res call(
      {String id,
      PartRequest partRequest,
      String sellerName,
      String sellerId,
      List<ParticulierMessage> messages,
      DateTime lastMessageAt,
      ConversationStatus status,
      bool hasUnreadMessages,
      int unreadCount,
      double? latestOfferPrice,
      int? latestOfferDeliveryDays,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? vehiclePlate,
      String? partType,
      List<String>? partNames,
      bool? hasNewMessages});

  $PartRequestCopyWith<$Res> get partRequest;
}

/// @nodoc
class _$ParticulierConversationCopyWithImpl<$Res,
        $Val extends ParticulierConversation>
    implements $ParticulierConversationCopyWith<$Res> {
  _$ParticulierConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParticulierConversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? partRequest = null,
    Object? sellerName = null,
    Object? sellerId = null,
    Object? messages = null,
    Object? lastMessageAt = null,
    Object? status = null,
    Object? hasUnreadMessages = null,
    Object? unreadCount = null,
    Object? latestOfferPrice = freezed,
    Object? latestOfferDeliveryDays = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? vehiclePlate = freezed,
    Object? partType = freezed,
    Object? partNames = freezed,
    Object? hasNewMessages = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      partRequest: null == partRequest
          ? _value.partRequest
          : partRequest // ignore: cast_nullable_to_non_nullable
              as PartRequest,
      sellerName: null == sellerName
          ? _value.sellerName
          : sellerName // ignore: cast_nullable_to_non_nullable
              as String,
      sellerId: null == sellerId
          ? _value.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String,
      messages: null == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<ParticulierMessage>,
      lastMessageAt: null == lastMessageAt
          ? _value.lastMessageAt
          : lastMessageAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ConversationStatus,
      hasUnreadMessages: null == hasUnreadMessages
          ? _value.hasUnreadMessages
          : hasUnreadMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      latestOfferPrice: freezed == latestOfferPrice
          ? _value.latestOfferPrice
          : latestOfferPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      latestOfferDeliveryDays: freezed == latestOfferDeliveryDays
          ? _value.latestOfferDeliveryDays
          : latestOfferDeliveryDays // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      vehiclePlate: freezed == vehiclePlate
          ? _value.vehiclePlate
          : vehiclePlate // ignore: cast_nullable_to_non_nullable
              as String?,
      partType: freezed == partType
          ? _value.partType
          : partType // ignore: cast_nullable_to_non_nullable
              as String?,
      partNames: freezed == partNames
          ? _value.partNames
          : partNames // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      hasNewMessages: freezed == hasNewMessages
          ? _value.hasNewMessages
          : hasNewMessages // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }

  /// Create a copy of ParticulierConversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PartRequestCopyWith<$Res> get partRequest {
    return $PartRequestCopyWith<$Res>(_value.partRequest, (value) {
      return _then(_value.copyWith(partRequest: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ParticulierConversationImplCopyWith<$Res>
    implements $ParticulierConversationCopyWith<$Res> {
  factory _$$ParticulierConversationImplCopyWith(
          _$ParticulierConversationImpl value,
          $Res Function(_$ParticulierConversationImpl) then) =
      __$$ParticulierConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      PartRequest partRequest,
      String sellerName,
      String sellerId,
      List<ParticulierMessage> messages,
      DateTime lastMessageAt,
      ConversationStatus status,
      bool hasUnreadMessages,
      int unreadCount,
      double? latestOfferPrice,
      int? latestOfferDeliveryDays,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? vehiclePlate,
      String? partType,
      List<String>? partNames,
      bool? hasNewMessages});

  @override
  $PartRequestCopyWith<$Res> get partRequest;
}

/// @nodoc
class __$$ParticulierConversationImplCopyWithImpl<$Res>
    extends _$ParticulierConversationCopyWithImpl<$Res,
        _$ParticulierConversationImpl>
    implements _$$ParticulierConversationImplCopyWith<$Res> {
  __$$ParticulierConversationImplCopyWithImpl(
      _$ParticulierConversationImpl _value,
      $Res Function(_$ParticulierConversationImpl) _then)
      : super(_value, _then);

  /// Create a copy of ParticulierConversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? partRequest = null,
    Object? sellerName = null,
    Object? sellerId = null,
    Object? messages = null,
    Object? lastMessageAt = null,
    Object? status = null,
    Object? hasUnreadMessages = null,
    Object? unreadCount = null,
    Object? latestOfferPrice = freezed,
    Object? latestOfferDeliveryDays = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? vehiclePlate = freezed,
    Object? partType = freezed,
    Object? partNames = freezed,
    Object? hasNewMessages = freezed,
  }) {
    return _then(_$ParticulierConversationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      partRequest: null == partRequest
          ? _value.partRequest
          : partRequest // ignore: cast_nullable_to_non_nullable
              as PartRequest,
      sellerName: null == sellerName
          ? _value.sellerName
          : sellerName // ignore: cast_nullable_to_non_nullable
              as String,
      sellerId: null == sellerId
          ? _value.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String,
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<ParticulierMessage>,
      lastMessageAt: null == lastMessageAt
          ? _value.lastMessageAt
          : lastMessageAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ConversationStatus,
      hasUnreadMessages: null == hasUnreadMessages
          ? _value.hasUnreadMessages
          : hasUnreadMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      latestOfferPrice: freezed == latestOfferPrice
          ? _value.latestOfferPrice
          : latestOfferPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      latestOfferDeliveryDays: freezed == latestOfferDeliveryDays
          ? _value.latestOfferDeliveryDays
          : latestOfferDeliveryDays // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      vehiclePlate: freezed == vehiclePlate
          ? _value.vehiclePlate
          : vehiclePlate // ignore: cast_nullable_to_non_nullable
              as String?,
      partType: freezed == partType
          ? _value.partType
          : partType // ignore: cast_nullable_to_non_nullable
              as String?,
      partNames: freezed == partNames
          ? _value._partNames
          : partNames // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      hasNewMessages: freezed == hasNewMessages
          ? _value.hasNewMessages
          : hasNewMessages // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc

class _$ParticulierConversationImpl implements _ParticulierConversation {
  const _$ParticulierConversationImpl(
      {required this.id,
      required this.partRequest,
      required this.sellerName,
      required this.sellerId,
      required final List<ParticulierMessage> messages,
      required this.lastMessageAt,
      required this.status,
      this.hasUnreadMessages = false,
      this.unreadCount = 0,
      this.latestOfferPrice,
      this.latestOfferDeliveryDays,
      this.createdAt,
      this.updatedAt,
      this.vehiclePlate,
      this.partType,
      final List<String>? partNames,
      this.hasNewMessages})
      : _messages = messages,
        _partNames = partNames;

  @override
  final String id;
  @override
  final PartRequest partRequest;
  @override
  final String sellerName;
  @override
  final String sellerId;
  final List<ParticulierMessage> _messages;
  @override
  List<ParticulierMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  final DateTime lastMessageAt;
  @override
  final ConversationStatus status;
  @override
  @JsonKey()
  final bool hasUnreadMessages;
  @override
  @JsonKey()
  final int unreadCount;
  @override
  final double? latestOfferPrice;
  @override
  final int? latestOfferDeliveryDays;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? vehiclePlate;
  @override
  final String? partType;
  final List<String>? _partNames;
  @override
  List<String>? get partNames {
    final value = _partNames;
    if (value == null) return null;
    if (_partNames is EqualUnmodifiableListView) return _partNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool? hasNewMessages;

  @override
  String toString() {
    return 'ParticulierConversation(id: $id, partRequest: $partRequest, sellerName: $sellerName, sellerId: $sellerId, messages: $messages, lastMessageAt: $lastMessageAt, status: $status, hasUnreadMessages: $hasUnreadMessages, unreadCount: $unreadCount, latestOfferPrice: $latestOfferPrice, latestOfferDeliveryDays: $latestOfferDeliveryDays, createdAt: $createdAt, updatedAt: $updatedAt, vehiclePlate: $vehiclePlate, partType: $partType, partNames: $partNames, hasNewMessages: $hasNewMessages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParticulierConversationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.partRequest, partRequest) ||
                other.partRequest == partRequest) &&
            (identical(other.sellerName, sellerName) ||
                other.sellerName == sellerName) &&
            (identical(other.sellerId, sellerId) ||
                other.sellerId == sellerId) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.hasUnreadMessages, hasUnreadMessages) ||
                other.hasUnreadMessages == hasUnreadMessages) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.latestOfferPrice, latestOfferPrice) ||
                other.latestOfferPrice == latestOfferPrice) &&
            (identical(
                    other.latestOfferDeliveryDays, latestOfferDeliveryDays) ||
                other.latestOfferDeliveryDays == latestOfferDeliveryDays) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.vehiclePlate, vehiclePlate) ||
                other.vehiclePlate == vehiclePlate) &&
            (identical(other.partType, partType) ||
                other.partType == partType) &&
            const DeepCollectionEquality()
                .equals(other._partNames, _partNames) &&
            (identical(other.hasNewMessages, hasNewMessages) ||
                other.hasNewMessages == hasNewMessages));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      partRequest,
      sellerName,
      sellerId,
      const DeepCollectionEquality().hash(_messages),
      lastMessageAt,
      status,
      hasUnreadMessages,
      unreadCount,
      latestOfferPrice,
      latestOfferDeliveryDays,
      createdAt,
      updatedAt,
      vehiclePlate,
      partType,
      const DeepCollectionEquality().hash(_partNames),
      hasNewMessages);

  /// Create a copy of ParticulierConversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParticulierConversationImplCopyWith<_$ParticulierConversationImpl>
      get copyWith => __$$ParticulierConversationImplCopyWithImpl<
          _$ParticulierConversationImpl>(this, _$identity);
}

abstract class _ParticulierConversation implements ParticulierConversation {
  const factory _ParticulierConversation(
      {required final String id,
      required final PartRequest partRequest,
      required final String sellerName,
      required final String sellerId,
      required final List<ParticulierMessage> messages,
      required final DateTime lastMessageAt,
      required final ConversationStatus status,
      final bool hasUnreadMessages,
      final int unreadCount,
      final double? latestOfferPrice,
      final int? latestOfferDeliveryDays,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final String? vehiclePlate,
      final String? partType,
      final List<String>? partNames,
      final bool? hasNewMessages}) = _$ParticulierConversationImpl;

  @override
  String get id;
  @override
  PartRequest get partRequest;
  @override
  String get sellerName;
  @override
  String get sellerId;
  @override
  List<ParticulierMessage> get messages;
  @override
  DateTime get lastMessageAt;
  @override
  ConversationStatus get status;
  @override
  bool get hasUnreadMessages;
  @override
  int get unreadCount;
  @override
  double? get latestOfferPrice;
  @override
  int? get latestOfferDeliveryDays;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  String? get vehiclePlate;
  @override
  String? get partType;
  @override
  List<String>? get partNames;
  @override
  bool? get hasNewMessages;

  /// Create a copy of ParticulierConversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParticulierConversationImplCopyWith<_$ParticulierConversationImpl>
      get copyWith => throw _privateConstructorUsedError;
}

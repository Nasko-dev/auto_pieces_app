// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_ads_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UnifiedItem {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PartAdvertisement advertisement) advertisement,
    required TResult Function(PartRequest request) request,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PartAdvertisement advertisement)? advertisement,
    TResult? Function(PartRequest request)? request,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PartAdvertisement advertisement)? advertisement,
    TResult Function(PartRequest request)? request,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Advertisement value) advertisement,
    required TResult Function(_Request value) request,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Advertisement value)? advertisement,
    TResult? Function(_Request value)? request,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Advertisement value)? advertisement,
    TResult Function(_Request value)? request,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnifiedItemCopyWith<$Res> {
  factory $UnifiedItemCopyWith(
          UnifiedItem value, $Res Function(UnifiedItem) then) =
      _$UnifiedItemCopyWithImpl<$Res, UnifiedItem>;
}

/// @nodoc
class _$UnifiedItemCopyWithImpl<$Res, $Val extends UnifiedItem>
    implements $UnifiedItemCopyWith<$Res> {
  _$UnifiedItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UnifiedItem
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$AdvertisementImplCopyWith<$Res> {
  factory _$$AdvertisementImplCopyWith(
          _$AdvertisementImpl value, $Res Function(_$AdvertisementImpl) then) =
      __$$AdvertisementImplCopyWithImpl<$Res>;
  @useResult
  $Res call({PartAdvertisement advertisement});
}

/// @nodoc
class __$$AdvertisementImplCopyWithImpl<$Res>
    extends _$UnifiedItemCopyWithImpl<$Res, _$AdvertisementImpl>
    implements _$$AdvertisementImplCopyWith<$Res> {
  __$$AdvertisementImplCopyWithImpl(
      _$AdvertisementImpl _value, $Res Function(_$AdvertisementImpl) _then)
      : super(_value, _then);

  /// Create a copy of UnifiedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? advertisement = null,
  }) {
    return _then(_$AdvertisementImpl(
      null == advertisement
          ? _value.advertisement
          : advertisement // ignore: cast_nullable_to_non_nullable
              as PartAdvertisement,
    ));
  }
}

/// @nodoc

class _$AdvertisementImpl implements _Advertisement {
  const _$AdvertisementImpl(this.advertisement);

  @override
  final PartAdvertisement advertisement;

  @override
  String toString() {
    return 'UnifiedItem.advertisement(advertisement: $advertisement)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdvertisementImpl &&
            (identical(other.advertisement, advertisement) ||
                other.advertisement == advertisement));
  }

  @override
  int get hashCode => Object.hash(runtimeType, advertisement);

  /// Create a copy of UnifiedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdvertisementImplCopyWith<_$AdvertisementImpl> get copyWith =>
      __$$AdvertisementImplCopyWithImpl<_$AdvertisementImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PartAdvertisement advertisement) advertisement,
    required TResult Function(PartRequest request) request,
  }) {
    return advertisement(this.advertisement);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PartAdvertisement advertisement)? advertisement,
    TResult? Function(PartRequest request)? request,
  }) {
    return advertisement?.call(this.advertisement);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PartAdvertisement advertisement)? advertisement,
    TResult Function(PartRequest request)? request,
    required TResult orElse(),
  }) {
    if (advertisement != null) {
      return advertisement(this.advertisement);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Advertisement value) advertisement,
    required TResult Function(_Request value) request,
  }) {
    return advertisement(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Advertisement value)? advertisement,
    TResult? Function(_Request value)? request,
  }) {
    return advertisement?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Advertisement value)? advertisement,
    TResult Function(_Request value)? request,
    required TResult orElse(),
  }) {
    if (advertisement != null) {
      return advertisement(this);
    }
    return orElse();
  }
}

abstract class _Advertisement implements UnifiedItem {
  const factory _Advertisement(final PartAdvertisement advertisement) =
      _$AdvertisementImpl;

  PartAdvertisement get advertisement;

  /// Create a copy of UnifiedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdvertisementImplCopyWith<_$AdvertisementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RequestImplCopyWith<$Res> {
  factory _$$RequestImplCopyWith(
          _$RequestImpl value, $Res Function(_$RequestImpl) then) =
      __$$RequestImplCopyWithImpl<$Res>;
  @useResult
  $Res call({PartRequest request});

  $PartRequestCopyWith<$Res> get request;
}

/// @nodoc
class __$$RequestImplCopyWithImpl<$Res>
    extends _$UnifiedItemCopyWithImpl<$Res, _$RequestImpl>
    implements _$$RequestImplCopyWith<$Res> {
  __$$RequestImplCopyWithImpl(
      _$RequestImpl _value, $Res Function(_$RequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of UnifiedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? request = null,
  }) {
    return _then(_$RequestImpl(
      null == request
          ? _value.request
          : request // ignore: cast_nullable_to_non_nullable
              as PartRequest,
    ));
  }

  /// Create a copy of UnifiedItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PartRequestCopyWith<$Res> get request {
    return $PartRequestCopyWith<$Res>(_value.request, (value) {
      return _then(_value.copyWith(request: value));
    });
  }
}

/// @nodoc

class _$RequestImpl implements _Request {
  const _$RequestImpl(this.request);

  @override
  final PartRequest request;

  @override
  String toString() {
    return 'UnifiedItem.request(request: $request)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestImpl &&
            (identical(other.request, request) || other.request == request));
  }

  @override
  int get hashCode => Object.hash(runtimeType, request);

  /// Create a copy of UnifiedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestImplCopyWith<_$RequestImpl> get copyWith =>
      __$$RequestImplCopyWithImpl<_$RequestImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PartAdvertisement advertisement) advertisement,
    required TResult Function(PartRequest request) request,
  }) {
    return request(this.request);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PartAdvertisement advertisement)? advertisement,
    TResult? Function(PartRequest request)? request,
  }) {
    return request?.call(this.request);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PartAdvertisement advertisement)? advertisement,
    TResult Function(PartRequest request)? request,
    required TResult orElse(),
  }) {
    if (request != null) {
      return request(this.request);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Advertisement value) advertisement,
    required TResult Function(_Request value) request,
  }) {
    return request(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Advertisement value)? advertisement,
    TResult? Function(_Request value)? request,
  }) {
    return request?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Advertisement value)? advertisement,
    TResult Function(_Request value)? request,
    required TResult orElse(),
  }) {
    if (request != null) {
      return request(this);
    }
    return orElse();
  }
}

abstract class _Request implements UnifiedItem {
  const factory _Request(final PartRequest request) = _$RequestImpl;

  PartRequest get request;

  /// Create a copy of UnifiedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RequestImplCopyWith<_$RequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

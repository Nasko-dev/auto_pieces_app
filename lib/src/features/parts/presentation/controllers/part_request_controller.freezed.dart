// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'part_request_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PartRequestState {
  List<PartRequest> get requests => throw _privateConstructorUsedError;
  List<SellerResponse> get responses => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isCreating => throw _privateConstructorUsedError;
  bool get isLoadingResponses => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  PartRequest? get selectedRequest => throw _privateConstructorUsedError;

  /// Create a copy of PartRequestState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PartRequestStateCopyWith<PartRequestState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartRequestStateCopyWith<$Res> {
  factory $PartRequestStateCopyWith(
          PartRequestState value, $Res Function(PartRequestState) then) =
      _$PartRequestStateCopyWithImpl<$Res, PartRequestState>;
  @useResult
  $Res call(
      {List<PartRequest> requests,
      List<SellerResponse> responses,
      bool isLoading,
      bool isCreating,
      bool isLoadingResponses,
      String? error,
      PartRequest? selectedRequest});

  $PartRequestCopyWith<$Res>? get selectedRequest;
}

/// @nodoc
class _$PartRequestStateCopyWithImpl<$Res, $Val extends PartRequestState>
    implements $PartRequestStateCopyWith<$Res> {
  _$PartRequestStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PartRequestState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requests = null,
    Object? responses = null,
    Object? isLoading = null,
    Object? isCreating = null,
    Object? isLoadingResponses = null,
    Object? error = freezed,
    Object? selectedRequest = freezed,
  }) {
    return _then(_value.copyWith(
      requests: null == requests
          ? _value.requests
          : requests // ignore: cast_nullable_to_non_nullable
              as List<PartRequest>,
      responses: null == responses
          ? _value.responses
          : responses // ignore: cast_nullable_to_non_nullable
              as List<SellerResponse>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isCreating: null == isCreating
          ? _value.isCreating
          : isCreating // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingResponses: null == isLoadingResponses
          ? _value.isLoadingResponses
          : isLoadingResponses // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedRequest: freezed == selectedRequest
          ? _value.selectedRequest
          : selectedRequest // ignore: cast_nullable_to_non_nullable
              as PartRequest?,
    ) as $Val);
  }

  /// Create a copy of PartRequestState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PartRequestCopyWith<$Res>? get selectedRequest {
    if (_value.selectedRequest == null) {
      return null;
    }

    return $PartRequestCopyWith<$Res>(_value.selectedRequest!, (value) {
      return _then(_value.copyWith(selectedRequest: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PartRequestStateImplCopyWith<$Res>
    implements $PartRequestStateCopyWith<$Res> {
  factory _$$PartRequestStateImplCopyWith(_$PartRequestStateImpl value,
          $Res Function(_$PartRequestStateImpl) then) =
      __$$PartRequestStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<PartRequest> requests,
      List<SellerResponse> responses,
      bool isLoading,
      bool isCreating,
      bool isLoadingResponses,
      String? error,
      PartRequest? selectedRequest});

  @override
  $PartRequestCopyWith<$Res>? get selectedRequest;
}

/// @nodoc
class __$$PartRequestStateImplCopyWithImpl<$Res>
    extends _$PartRequestStateCopyWithImpl<$Res, _$PartRequestStateImpl>
    implements _$$PartRequestStateImplCopyWith<$Res> {
  __$$PartRequestStateImplCopyWithImpl(_$PartRequestStateImpl _value,
      $Res Function(_$PartRequestStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PartRequestState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requests = null,
    Object? responses = null,
    Object? isLoading = null,
    Object? isCreating = null,
    Object? isLoadingResponses = null,
    Object? error = freezed,
    Object? selectedRequest = freezed,
  }) {
    return _then(_$PartRequestStateImpl(
      requests: null == requests
          ? _value._requests
          : requests // ignore: cast_nullable_to_non_nullable
              as List<PartRequest>,
      responses: null == responses
          ? _value._responses
          : responses // ignore: cast_nullable_to_non_nullable
              as List<SellerResponse>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isCreating: null == isCreating
          ? _value.isCreating
          : isCreating // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingResponses: null == isLoadingResponses
          ? _value.isLoadingResponses
          : isLoadingResponses // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedRequest: freezed == selectedRequest
          ? _value.selectedRequest
          : selectedRequest // ignore: cast_nullable_to_non_nullable
              as PartRequest?,
    ));
  }
}

/// @nodoc

class _$PartRequestStateImpl implements _PartRequestState {
  const _$PartRequestStateImpl(
      {final List<PartRequest> requests = const [],
      final List<SellerResponse> responses = const [],
      this.isLoading = false,
      this.isCreating = false,
      this.isLoadingResponses = false,
      this.error,
      this.selectedRequest})
      : _requests = requests,
        _responses = responses;

  final List<PartRequest> _requests;
  @override
  @JsonKey()
  List<PartRequest> get requests {
    if (_requests is EqualUnmodifiableListView) return _requests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requests);
  }

  final List<SellerResponse> _responses;
  @override
  @JsonKey()
  List<SellerResponse> get responses {
    if (_responses is EqualUnmodifiableListView) return _responses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_responses);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isCreating;
  @override
  @JsonKey()
  final bool isLoadingResponses;
  @override
  final String? error;
  @override
  final PartRequest? selectedRequest;

  @override
  String toString() {
    return 'PartRequestState(requests: $requests, responses: $responses, isLoading: $isLoading, isCreating: $isCreating, isLoadingResponses: $isLoadingResponses, error: $error, selectedRequest: $selectedRequest)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartRequestStateImpl &&
            const DeepCollectionEquality().equals(other._requests, _requests) &&
            const DeepCollectionEquality()
                .equals(other._responses, _responses) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isCreating, isCreating) ||
                other.isCreating == isCreating) &&
            (identical(other.isLoadingResponses, isLoadingResponses) ||
                other.isLoadingResponses == isLoadingResponses) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.selectedRequest, selectedRequest) ||
                other.selectedRequest == selectedRequest));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_requests),
      const DeepCollectionEquality().hash(_responses),
      isLoading,
      isCreating,
      isLoadingResponses,
      error,
      selectedRequest);

  /// Create a copy of PartRequestState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PartRequestStateImplCopyWith<_$PartRequestStateImpl> get copyWith =>
      __$$PartRequestStateImplCopyWithImpl<_$PartRequestStateImpl>(
          this, _$identity);
}

abstract class _PartRequestState implements PartRequestState {
  const factory _PartRequestState(
      {final List<PartRequest> requests,
      final List<SellerResponse> responses,
      final bool isLoading,
      final bool isCreating,
      final bool isLoadingResponses,
      final String? error,
      final PartRequest? selectedRequest}) = _$PartRequestStateImpl;

  @override
  List<PartRequest> get requests;
  @override
  List<SellerResponse> get responses;
  @override
  bool get isLoading;
  @override
  bool get isCreating;
  @override
  bool get isLoadingResponses;
  @override
  String? get error;
  @override
  PartRequest? get selectedRequest;

  /// Create a copy of PartRequestState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PartRequestStateImplCopyWith<_$PartRequestStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

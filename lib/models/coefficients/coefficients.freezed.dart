// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coefficients.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Coefficients _$CoefficientsFromJson(Map<String, dynamic> json) {
  return _Coefficients.fromJson(json);
}

/// @nodoc
mixin _$Coefficients {
  double get b0 => throw _privateConstructorUsedError;
  double get b1 => throw _privateConstructorUsedError;
  double get b2 => throw _privateConstructorUsedError;
  double get b3 => throw _privateConstructorUsedError;
  double get sigma => throw _privateConstructorUsedError;

  /// Serializes this Coefficients to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Coefficients
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoefficientsCopyWith<Coefficients> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoefficientsCopyWith<$Res> {
  factory $CoefficientsCopyWith(
          Coefficients value, $Res Function(Coefficients) then) =
      _$CoefficientsCopyWithImpl<$Res, Coefficients>;
  @useResult
  $Res call({double b0, double b1, double b2, double b3, double sigma});
}

/// @nodoc
class _$CoefficientsCopyWithImpl<$Res, $Val extends Coefficients>
    implements $CoefficientsCopyWith<$Res> {
  _$CoefficientsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Coefficients
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? b0 = null,
    Object? b1 = null,
    Object? b2 = null,
    Object? b3 = null,
    Object? sigma = null,
  }) {
    return _then(_value.copyWith(
      b0: null == b0
          ? _value.b0
          : b0 // ignore: cast_nullable_to_non_nullable
              as double,
      b1: null == b1
          ? _value.b1
          : b1 // ignore: cast_nullable_to_non_nullable
              as double,
      b2: null == b2
          ? _value.b2
          : b2 // ignore: cast_nullable_to_non_nullable
              as double,
      b3: null == b3
          ? _value.b3
          : b3 // ignore: cast_nullable_to_non_nullable
              as double,
      sigma: null == sigma
          ? _value.sigma
          : sigma // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CoefficientsImplCopyWith<$Res>
    implements $CoefficientsCopyWith<$Res> {
  factory _$$CoefficientsImplCopyWith(
          _$CoefficientsImpl value, $Res Function(_$CoefficientsImpl) then) =
      __$$CoefficientsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double b0, double b1, double b2, double b3, double sigma});
}

/// @nodoc
class __$$CoefficientsImplCopyWithImpl<$Res>
    extends _$CoefficientsCopyWithImpl<$Res, _$CoefficientsImpl>
    implements _$$CoefficientsImplCopyWith<$Res> {
  __$$CoefficientsImplCopyWithImpl(
      _$CoefficientsImpl _value, $Res Function(_$CoefficientsImpl) _then)
      : super(_value, _then);

  /// Create a copy of Coefficients
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? b0 = null,
    Object? b1 = null,
    Object? b2 = null,
    Object? b3 = null,
    Object? sigma = null,
  }) {
    return _then(_$CoefficientsImpl(
      b0: null == b0
          ? _value.b0
          : b0 // ignore: cast_nullable_to_non_nullable
              as double,
      b1: null == b1
          ? _value.b1
          : b1 // ignore: cast_nullable_to_non_nullable
              as double,
      b2: null == b2
          ? _value.b2
          : b2 // ignore: cast_nullable_to_non_nullable
              as double,
      b3: null == b3
          ? _value.b3
          : b3 // ignore: cast_nullable_to_non_nullable
              as double,
      sigma: null == sigma
          ? _value.sigma
          : sigma // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoefficientsImpl implements _Coefficients {
  const _$CoefficientsImpl(
      {required this.b0,
      required this.b1,
      required this.b2,
      required this.b3,
      required this.sigma});

  factory _$CoefficientsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoefficientsImplFromJson(json);

  @override
  final double b0;
  @override
  final double b1;
  @override
  final double b2;
  @override
  final double b3;
  @override
  final double sigma;

  @override
  String toString() {
    return 'Coefficients(b0: $b0, b1: $b1, b2: $b2, b3: $b3, sigma: $sigma)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoefficientsImpl &&
            (identical(other.b0, b0) || other.b0 == b0) &&
            (identical(other.b1, b1) || other.b1 == b1) &&
            (identical(other.b2, b2) || other.b2 == b2) &&
            (identical(other.b3, b3) || other.b3 == b3) &&
            (identical(other.sigma, sigma) || other.sigma == sigma));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, b0, b1, b2, b3, sigma);

  /// Create a copy of Coefficients
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoefficientsImplCopyWith<_$CoefficientsImpl> get copyWith =>
      __$$CoefficientsImplCopyWithImpl<_$CoefficientsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoefficientsImplToJson(
      this,
    );
  }
}

abstract class _Coefficients implements Coefficients {
  const factory _Coefficients(
      {required final double b0,
      required final double b1,
      required final double b2,
      required final double b3,
      required final double sigma}) = _$CoefficientsImpl;

  factory _Coefficients.fromJson(Map<String, dynamic> json) =
      _$CoefficientsImpl.fromJson;

  @override
  double get b0;
  @override
  double get b1;
  @override
  double get b2;
  @override
  double get b3;
  @override
  double get sigma;

  /// Create a copy of Coefficients
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoefficientsImplCopyWith<_$CoefficientsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

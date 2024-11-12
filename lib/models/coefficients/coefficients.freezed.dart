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
  List<double> get b => throw _privateConstructorUsedError;
  double get epsilon => throw _privateConstructorUsedError;

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
  $Res call({List<double> b, double epsilon});
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
    Object? b = null,
    Object? epsilon = null,
  }) {
    return _then(_value.copyWith(
      b: null == b
          ? _value.b
          : b // ignore: cast_nullable_to_non_nullable
              as List<double>,
      epsilon: null == epsilon
          ? _value.epsilon
          : epsilon // ignore: cast_nullable_to_non_nullable
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
  $Res call({List<double> b, double epsilon});
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
    Object? b = null,
    Object? epsilon = null,
  }) {
    return _then(_$CoefficientsImpl(
      b: null == b
          ? _value._b
          : b // ignore: cast_nullable_to_non_nullable
              as List<double>,
      epsilon: null == epsilon
          ? _value.epsilon
          : epsilon // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoefficientsImpl implements _Coefficients {
  const _$CoefficientsImpl(
      {required final List<double> b, required this.epsilon})
      : _b = b;

  factory _$CoefficientsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoefficientsImplFromJson(json);

  final List<double> _b;
  @override
  List<double> get b {
    if (_b is EqualUnmodifiableListView) return _b;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_b);
  }

  @override
  final double epsilon;

  @override
  String toString() {
    return 'Coefficients(b: $b, epsilon: $epsilon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoefficientsImpl &&
            const DeepCollectionEquality().equals(other._b, _b) &&
            (identical(other.epsilon, epsilon) || other.epsilon == epsilon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_b), epsilon);

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
      {required final List<double> b,
      required final double epsilon}) = _$CoefficientsImpl;

  factory _Coefficients.fromJson(Map<String, dynamic> json) =
      _$CoefficientsImpl.fromJson;

  @override
  List<double> get b;
  @override
  double get epsilon;

  /// Create a copy of Coefficients
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoefficientsImplCopyWith<_$CoefficientsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

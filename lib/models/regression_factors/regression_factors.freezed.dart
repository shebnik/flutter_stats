// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'regression_factors.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RegressionFactors _$RegressionFactorsFromJson(Map<String, dynamic> json) {
  return _RegressionFactors.fromJson(json);
}

/// @nodoc
mixin _$RegressionFactors {
  double get y => throw _privateConstructorUsedError;
  List<double> get x => throw _privateConstructorUsedError;

  /// Serializes this RegressionFactors to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RegressionFactors
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegressionFactorsCopyWith<RegressionFactors> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegressionFactorsCopyWith<$Res> {
  factory $RegressionFactorsCopyWith(
          RegressionFactors value, $Res Function(RegressionFactors) then) =
      _$RegressionFactorsCopyWithImpl<$Res, RegressionFactors>;
  @useResult
  $Res call({double y, List<double> x});
}

/// @nodoc
class _$RegressionFactorsCopyWithImpl<$Res, $Val extends RegressionFactors>
    implements $RegressionFactorsCopyWith<$Res> {
  _$RegressionFactorsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegressionFactors
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? y = null,
    Object? x = null,
  }) {
    return _then(_value.copyWith(
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
      x: null == x
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RegressionFactorsImplCopyWith<$Res>
    implements $RegressionFactorsCopyWith<$Res> {
  factory _$$RegressionFactorsImplCopyWith(_$RegressionFactorsImpl value,
          $Res Function(_$RegressionFactorsImpl) then) =
      __$$RegressionFactorsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double y, List<double> x});
}

/// @nodoc
class __$$RegressionFactorsImplCopyWithImpl<$Res>
    extends _$RegressionFactorsCopyWithImpl<$Res, _$RegressionFactorsImpl>
    implements _$$RegressionFactorsImplCopyWith<$Res> {
  __$$RegressionFactorsImplCopyWithImpl(_$RegressionFactorsImpl _value,
      $Res Function(_$RegressionFactorsImpl) _then)
      : super(_value, _then);

  /// Create a copy of RegressionFactors
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? y = null,
    Object? x = null,
  }) {
    return _then(_$RegressionFactorsImpl(
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
      x: null == x
          ? _value._x
          : x // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RegressionFactorsImpl implements _RegressionFactors {
  const _$RegressionFactorsImpl(
      {required this.y, required final List<double> x})
      : _x = x;

  factory _$RegressionFactorsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegressionFactorsImplFromJson(json);

  @override
  final double y;
  final List<double> _x;
  @override
  List<double> get x {
    if (_x is EqualUnmodifiableListView) return _x;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_x);
  }

  @override
  String toString() {
    return 'RegressionFactors(y: $y, x: $x)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegressionFactorsImpl &&
            (identical(other.y, y) || other.y == y) &&
            const DeepCollectionEquality().equals(other._x, _x));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, y, const DeepCollectionEquality().hash(_x));

  /// Create a copy of RegressionFactors
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegressionFactorsImplCopyWith<_$RegressionFactorsImpl> get copyWith =>
      __$$RegressionFactorsImplCopyWithImpl<_$RegressionFactorsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RegressionFactorsImplToJson(
      this,
    );
  }
}

abstract class _RegressionFactors implements RegressionFactors {
  const factory _RegressionFactors(
      {required final double y,
      required final List<double> x}) = _$RegressionFactorsImpl;

  factory _RegressionFactors.fromJson(Map<String, dynamic> json) =
      _$RegressionFactorsImpl.fromJson;

  @override
  double get y;
  @override
  List<double> get x;

  /// Create a copy of RegressionFactors
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegressionFactorsImplCopyWith<_$RegressionFactorsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

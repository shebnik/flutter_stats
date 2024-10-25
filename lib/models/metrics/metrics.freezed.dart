// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Metrics _$MetricsFromJson(Map<String, dynamic> json) {
  return _Metrics.fromJson(json);
}

/// @nodoc
mixin _$Metrics {
  double get y => throw _privateConstructorUsedError;
  double get x1 => throw _privateConstructorUsedError;
  double? get x2 => throw _privateConstructorUsedError;
  double? get x3 => throw _privateConstructorUsedError;
  double? get noc => throw _privateConstructorUsedError;

  /// Serializes this Metrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Metrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MetricsCopyWith<Metrics> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MetricsCopyWith<$Res> {
  factory $MetricsCopyWith(Metrics value, $Res Function(Metrics) then) =
      _$MetricsCopyWithImpl<$Res, Metrics>;
  @useResult
  $Res call({double y, double x1, double? x2, double? x3, double? noc});
}

/// @nodoc
class _$MetricsCopyWithImpl<$Res, $Val extends Metrics>
    implements $MetricsCopyWith<$Res> {
  _$MetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Metrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? y = null,
    Object? x1 = null,
    Object? x2 = freezed,
    Object? x3 = freezed,
    Object? noc = freezed,
  }) {
    return _then(_value.copyWith(
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
      x1: null == x1
          ? _value.x1
          : x1 // ignore: cast_nullable_to_non_nullable
              as double,
      x2: freezed == x2
          ? _value.x2
          : x2 // ignore: cast_nullable_to_non_nullable
              as double?,
      x3: freezed == x3
          ? _value.x3
          : x3 // ignore: cast_nullable_to_non_nullable
              as double?,
      noc: freezed == noc
          ? _value.noc
          : noc // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MetricsImplCopyWith<$Res> implements $MetricsCopyWith<$Res> {
  factory _$$MetricsImplCopyWith(
          _$MetricsImpl value, $Res Function(_$MetricsImpl) then) =
      __$$MetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double y, double x1, double? x2, double? x3, double? noc});
}

/// @nodoc
class __$$MetricsImplCopyWithImpl<$Res>
    extends _$MetricsCopyWithImpl<$Res, _$MetricsImpl>
    implements _$$MetricsImplCopyWith<$Res> {
  __$$MetricsImplCopyWithImpl(
      _$MetricsImpl _value, $Res Function(_$MetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of Metrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? y = null,
    Object? x1 = null,
    Object? x2 = freezed,
    Object? x3 = freezed,
    Object? noc = freezed,
  }) {
    return _then(_$MetricsImpl(
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
      x1: null == x1
          ? _value.x1
          : x1 // ignore: cast_nullable_to_non_nullable
              as double,
      x2: freezed == x2
          ? _value.x2
          : x2 // ignore: cast_nullable_to_non_nullable
              as double?,
      x3: freezed == x3
          ? _value.x3
          : x3 // ignore: cast_nullable_to_non_nullable
              as double?,
      noc: freezed == noc
          ? _value.noc
          : noc // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MetricsImpl implements _Metrics {
  const _$MetricsImpl(
      {required this.y, required this.x1, this.x2, this.x3, this.noc});

  factory _$MetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MetricsImplFromJson(json);

  @override
  final double y;
  @override
  final double x1;
  @override
  final double? x2;
  @override
  final double? x3;
  @override
  final double? noc;

  @override
  String toString() {
    return 'Metrics(y: $y, x1: $x1, x2: $x2, x3: $x3, noc: $noc)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MetricsImpl &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.x1, x1) || other.x1 == x1) &&
            (identical(other.x2, x2) || other.x2 == x2) &&
            (identical(other.x3, x3) || other.x3 == x3) &&
            (identical(other.noc, noc) || other.noc == noc));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, y, x1, x2, x3, noc);

  /// Create a copy of Metrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MetricsImplCopyWith<_$MetricsImpl> get copyWith =>
      __$$MetricsImplCopyWithImpl<_$MetricsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MetricsImplToJson(
      this,
    );
  }
}

abstract class _Metrics implements Metrics {
  const factory _Metrics(
      {required final double y,
      required final double x1,
      final double? x2,
      final double? x3,
      final double? noc}) = _$MetricsImpl;

  factory _Metrics.fromJson(Map<String, dynamic> json) = _$MetricsImpl.fromJson;

  @override
  double get y;
  @override
  double get x1;
  @override
  double? get x2;
  @override
  double? get x3;
  @override
  double? get noc;

  /// Create a copy of Metrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MetricsImplCopyWith<_$MetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

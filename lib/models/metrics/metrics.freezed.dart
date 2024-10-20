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
  double? get dit => throw _privateConstructorUsedError;
  double? get rfc => throw _privateConstructorUsedError;
  double? get cbo => throw _privateConstructorUsedError;
  double? get wmc => throw _privateConstructorUsedError;
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
  $Res call({double? dit, double? rfc, double? cbo, double? wmc, double? noc});
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
    Object? dit = freezed,
    Object? rfc = freezed,
    Object? cbo = freezed,
    Object? wmc = freezed,
    Object? noc = freezed,
  }) {
    return _then(_value.copyWith(
      dit: freezed == dit
          ? _value.dit
          : dit // ignore: cast_nullable_to_non_nullable
              as double?,
      rfc: freezed == rfc
          ? _value.rfc
          : rfc // ignore: cast_nullable_to_non_nullable
              as double?,
      cbo: freezed == cbo
          ? _value.cbo
          : cbo // ignore: cast_nullable_to_non_nullable
              as double?,
      wmc: freezed == wmc
          ? _value.wmc
          : wmc // ignore: cast_nullable_to_non_nullable
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
  $Res call({double? dit, double? rfc, double? cbo, double? wmc, double? noc});
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
    Object? dit = freezed,
    Object? rfc = freezed,
    Object? cbo = freezed,
    Object? wmc = freezed,
    Object? noc = freezed,
  }) {
    return _then(_$MetricsImpl(
      dit: freezed == dit
          ? _value.dit
          : dit // ignore: cast_nullable_to_non_nullable
              as double?,
      rfc: freezed == rfc
          ? _value.rfc
          : rfc // ignore: cast_nullable_to_non_nullable
              as double?,
      cbo: freezed == cbo
          ? _value.cbo
          : cbo // ignore: cast_nullable_to_non_nullable
              as double?,
      wmc: freezed == wmc
          ? _value.wmc
          : wmc // ignore: cast_nullable_to_non_nullable
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
  const _$MetricsImpl({this.dit, this.rfc, this.cbo, this.wmc, this.noc});

  factory _$MetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MetricsImplFromJson(json);

  @override
  final double? dit;
  @override
  final double? rfc;
  @override
  final double? cbo;
  @override
  final double? wmc;
  @override
  final double? noc;

  @override
  String toString() {
    return 'Metrics(dit: $dit, rfc: $rfc, cbo: $cbo, wmc: $wmc, noc: $noc)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MetricsImpl &&
            (identical(other.dit, dit) || other.dit == dit) &&
            (identical(other.rfc, rfc) || other.rfc == rfc) &&
            (identical(other.cbo, cbo) || other.cbo == cbo) &&
            (identical(other.wmc, wmc) || other.wmc == wmc) &&
            (identical(other.noc, noc) || other.noc == noc));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, dit, rfc, cbo, wmc, noc);

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
      {final double? dit,
      final double? rfc,
      final double? cbo,
      final double? wmc,
      final double? noc}) = _$MetricsImpl;

  factory _Metrics.fromJson(Map<String, dynamic> json) = _$MetricsImpl.fromJson;

  @override
  double? get dit;
  @override
  double? get rfc;
  @override
  double? get cbo;
  @override
  double? get wmc;
  @override
  double? get noc;

  /// Create a copy of Metrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MetricsImplCopyWith<_$MetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

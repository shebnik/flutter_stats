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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Metrics _$MetricsFromJson(Map<String, dynamic> json) {
  return _Metrics.fromJson(json);
}

/// @nodoc
mixin _$Metrics {
  double? get linesOfCode => throw _privateConstructorUsedError;
  double? get cyclomaticComplexity => throw _privateConstructorUsedError;
  double? get numberOfMethods => throw _privateConstructorUsedError;
  double? get numberOfClasses => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MetricsCopyWith<Metrics> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MetricsCopyWith<$Res> {
  factory $MetricsCopyWith(Metrics value, $Res Function(Metrics) then) =
      _$MetricsCopyWithImpl<$Res, Metrics>;
  @useResult
  $Res call(
      {double? linesOfCode,
      double? cyclomaticComplexity,
      double? numberOfMethods,
      double? numberOfClasses});
}

/// @nodoc
class _$MetricsCopyWithImpl<$Res, $Val extends Metrics>
    implements $MetricsCopyWith<$Res> {
  _$MetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? linesOfCode = freezed,
    Object? cyclomaticComplexity = freezed,
    Object? numberOfMethods = freezed,
    Object? numberOfClasses = freezed,
  }) {
    return _then(_value.copyWith(
      linesOfCode: freezed == linesOfCode
          ? _value.linesOfCode
          : linesOfCode // ignore: cast_nullable_to_non_nullable
              as double?,
      cyclomaticComplexity: freezed == cyclomaticComplexity
          ? _value.cyclomaticComplexity
          : cyclomaticComplexity // ignore: cast_nullable_to_non_nullable
              as double?,
      numberOfMethods: freezed == numberOfMethods
          ? _value.numberOfMethods
          : numberOfMethods // ignore: cast_nullable_to_non_nullable
              as double?,
      numberOfClasses: freezed == numberOfClasses
          ? _value.numberOfClasses
          : numberOfClasses // ignore: cast_nullable_to_non_nullable
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
  $Res call(
      {double? linesOfCode,
      double? cyclomaticComplexity,
      double? numberOfMethods,
      double? numberOfClasses});
}

/// @nodoc
class __$$MetricsImplCopyWithImpl<$Res>
    extends _$MetricsCopyWithImpl<$Res, _$MetricsImpl>
    implements _$$MetricsImplCopyWith<$Res> {
  __$$MetricsImplCopyWithImpl(
      _$MetricsImpl _value, $Res Function(_$MetricsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? linesOfCode = freezed,
    Object? cyclomaticComplexity = freezed,
    Object? numberOfMethods = freezed,
    Object? numberOfClasses = freezed,
  }) {
    return _then(_$MetricsImpl(
      linesOfCode: freezed == linesOfCode
          ? _value.linesOfCode
          : linesOfCode // ignore: cast_nullable_to_non_nullable
              as double?,
      cyclomaticComplexity: freezed == cyclomaticComplexity
          ? _value.cyclomaticComplexity
          : cyclomaticComplexity // ignore: cast_nullable_to_non_nullable
              as double?,
      numberOfMethods: freezed == numberOfMethods
          ? _value.numberOfMethods
          : numberOfMethods // ignore: cast_nullable_to_non_nullable
              as double?,
      numberOfClasses: freezed == numberOfClasses
          ? _value.numberOfClasses
          : numberOfClasses // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MetricsImpl implements _Metrics {
  const _$MetricsImpl(
      {this.linesOfCode,
      this.cyclomaticComplexity,
      this.numberOfMethods,
      this.numberOfClasses});

  factory _$MetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MetricsImplFromJson(json);

  @override
  final double? linesOfCode;
  @override
  final double? cyclomaticComplexity;
  @override
  final double? numberOfMethods;
  @override
  final double? numberOfClasses;

  @override
  String toString() {
    return 'Metrics(linesOfCode: $linesOfCode, cyclomaticComplexity: $cyclomaticComplexity, numberOfMethods: $numberOfMethods, numberOfClasses: $numberOfClasses)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MetricsImpl &&
            (identical(other.linesOfCode, linesOfCode) ||
                other.linesOfCode == linesOfCode) &&
            (identical(other.cyclomaticComplexity, cyclomaticComplexity) ||
                other.cyclomaticComplexity == cyclomaticComplexity) &&
            (identical(other.numberOfMethods, numberOfMethods) ||
                other.numberOfMethods == numberOfMethods) &&
            (identical(other.numberOfClasses, numberOfClasses) ||
                other.numberOfClasses == numberOfClasses));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, linesOfCode,
      cyclomaticComplexity, numberOfMethods, numberOfClasses);

  @JsonKey(ignore: true)
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
      {final double? linesOfCode,
      final double? cyclomaticComplexity,
      final double? numberOfMethods,
      final double? numberOfClasses}) = _$MetricsImpl;

  factory _Metrics.fromJson(Map<String, dynamic> json) = _$MetricsImpl.fromJson;

  @override
  double? get linesOfCode;
  @override
  double? get cyclomaticComplexity;
  @override
  double? get numberOfMethods;
  @override
  double? get numberOfClasses;
  @override
  @JsonKey(ignore: true)
  _$$MetricsImplCopyWith<_$MetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

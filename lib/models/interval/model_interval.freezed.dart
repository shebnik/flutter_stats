// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model_interval.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ModelInterval _$ModelIntervalFromJson(Map<String, dynamic> json) {
  return _ModelInterval.fromJson(json);
}

/// @nodoc
mixin _$ModelInterval {
  int get index => throw _privateConstructorUsedError;
  double get calculatedValues => throw _privateConstructorUsedError;
  double get lowerConfidenceLimit => throw _privateConstructorUsedError;
  double get upperConfidenceLimit => throw _privateConstructorUsedError;
  double get lowerPredictionLimit => throw _privateConstructorUsedError;
  double get upperPredictionLimit => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ModelIntervalCopyWith<ModelInterval> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModelIntervalCopyWith<$Res> {
  factory $ModelIntervalCopyWith(
          ModelInterval value, $Res Function(ModelInterval) then) =
      _$ModelIntervalCopyWithImpl<$Res, ModelInterval>;
  @useResult
  $Res call(
      {int index,
      double calculatedValues,
      double lowerConfidenceLimit,
      double upperConfidenceLimit,
      double lowerPredictionLimit,
      double upperPredictionLimit});
}

/// @nodoc
class _$ModelIntervalCopyWithImpl<$Res, $Val extends ModelInterval>
    implements $ModelIntervalCopyWith<$Res> {
  _$ModelIntervalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? calculatedValues = null,
    Object? lowerConfidenceLimit = null,
    Object? upperConfidenceLimit = null,
    Object? lowerPredictionLimit = null,
    Object? upperPredictionLimit = null,
  }) {
    return _then(_value.copyWith(
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      calculatedValues: null == calculatedValues
          ? _value.calculatedValues
          : calculatedValues // ignore: cast_nullable_to_non_nullable
              as double,
      lowerConfidenceLimit: null == lowerConfidenceLimit
          ? _value.lowerConfidenceLimit
          : lowerConfidenceLimit // ignore: cast_nullable_to_non_nullable
              as double,
      upperConfidenceLimit: null == upperConfidenceLimit
          ? _value.upperConfidenceLimit
          : upperConfidenceLimit // ignore: cast_nullable_to_non_nullable
              as double,
      lowerPredictionLimit: null == lowerPredictionLimit
          ? _value.lowerPredictionLimit
          : lowerPredictionLimit // ignore: cast_nullable_to_non_nullable
              as double,
      upperPredictionLimit: null == upperPredictionLimit
          ? _value.upperPredictionLimit
          : upperPredictionLimit // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModelIntervalImplCopyWith<$Res>
    implements $ModelIntervalCopyWith<$Res> {
  factory _$$ModelIntervalImplCopyWith(
          _$ModelIntervalImpl value, $Res Function(_$ModelIntervalImpl) then) =
      __$$ModelIntervalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int index,
      double calculatedValues,
      double lowerConfidenceLimit,
      double upperConfidenceLimit,
      double lowerPredictionLimit,
      double upperPredictionLimit});
}

/// @nodoc
class __$$ModelIntervalImplCopyWithImpl<$Res>
    extends _$ModelIntervalCopyWithImpl<$Res, _$ModelIntervalImpl>
    implements _$$ModelIntervalImplCopyWith<$Res> {
  __$$ModelIntervalImplCopyWithImpl(
      _$ModelIntervalImpl _value, $Res Function(_$ModelIntervalImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? calculatedValues = null,
    Object? lowerConfidenceLimit = null,
    Object? upperConfidenceLimit = null,
    Object? lowerPredictionLimit = null,
    Object? upperPredictionLimit = null,
  }) {
    return _then(_$ModelIntervalImpl(
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      calculatedValues: null == calculatedValues
          ? _value.calculatedValues
          : calculatedValues // ignore: cast_nullable_to_non_nullable
              as double,
      lowerConfidenceLimit: null == lowerConfidenceLimit
          ? _value.lowerConfidenceLimit
          : lowerConfidenceLimit // ignore: cast_nullable_to_non_nullable
              as double,
      upperConfidenceLimit: null == upperConfidenceLimit
          ? _value.upperConfidenceLimit
          : upperConfidenceLimit // ignore: cast_nullable_to_non_nullable
              as double,
      lowerPredictionLimit: null == lowerPredictionLimit
          ? _value.lowerPredictionLimit
          : lowerPredictionLimit // ignore: cast_nullable_to_non_nullable
              as double,
      upperPredictionLimit: null == upperPredictionLimit
          ? _value.upperPredictionLimit
          : upperPredictionLimit // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModelIntervalImpl implements _ModelInterval {
  const _$ModelIntervalImpl(
      {required this.index,
      required this.calculatedValues,
      required this.lowerConfidenceLimit,
      required this.upperConfidenceLimit,
      required this.lowerPredictionLimit,
      required this.upperPredictionLimit});

  factory _$ModelIntervalImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModelIntervalImplFromJson(json);

  @override
  final int index;
  @override
  final double calculatedValues;
  @override
  final double lowerConfidenceLimit;
  @override
  final double upperConfidenceLimit;
  @override
  final double lowerPredictionLimit;
  @override
  final double upperPredictionLimit;

  @override
  String toString() {
    return 'ModelInterval(index: $index, calculatedValues: $calculatedValues, lowerConfidenceLimit: $lowerConfidenceLimit, upperConfidenceLimit: $upperConfidenceLimit, lowerPredictionLimit: $lowerPredictionLimit, upperPredictionLimit: $upperPredictionLimit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelIntervalImpl &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.calculatedValues, calculatedValues) ||
                other.calculatedValues == calculatedValues) &&
            (identical(other.lowerConfidenceLimit, lowerConfidenceLimit) ||
                other.lowerConfidenceLimit == lowerConfidenceLimit) &&
            (identical(other.upperConfidenceLimit, upperConfidenceLimit) ||
                other.upperConfidenceLimit == upperConfidenceLimit) &&
            (identical(other.lowerPredictionLimit, lowerPredictionLimit) ||
                other.lowerPredictionLimit == lowerPredictionLimit) &&
            (identical(other.upperPredictionLimit, upperPredictionLimit) ||
                other.upperPredictionLimit == upperPredictionLimit));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      index,
      calculatedValues,
      lowerConfidenceLimit,
      upperConfidenceLimit,
      lowerPredictionLimit,
      upperPredictionLimit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ModelIntervalImplCopyWith<_$ModelIntervalImpl> get copyWith =>
      __$$ModelIntervalImplCopyWithImpl<_$ModelIntervalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModelIntervalImplToJson(
      this,
    );
  }
}

abstract class _ModelInterval implements ModelInterval {
  const factory _ModelInterval(
      {required final int index,
      required final double calculatedValues,
      required final double lowerConfidenceLimit,
      required final double upperConfidenceLimit,
      required final double lowerPredictionLimit,
      required final double upperPredictionLimit}) = _$ModelIntervalImpl;

  factory _ModelInterval.fromJson(Map<String, dynamic> json) =
      _$ModelIntervalImpl.fromJson;

  @override
  int get index;
  @override
  double get calculatedValues;
  @override
  double get lowerConfidenceLimit;
  @override
  double get upperConfidenceLimit;
  @override
  double get lowerPredictionLimit;
  @override
  double get upperPredictionLimit;
  @override
  @JsonKey(ignore: true)
  _$$ModelIntervalImplCopyWith<_$ModelIntervalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

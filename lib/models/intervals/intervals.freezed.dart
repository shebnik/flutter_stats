// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'intervals.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Intervals _$IntervalsFromJson(Map<String, dynamic> json) {
  return _Intervals.fromJson(json);
}

/// @nodoc
mixin _$Intervals {
  List<double> get y => throw _privateConstructorUsedError;
  List<double> get yHat => throw _privateConstructorUsedError;
  List<double> get predictionLower => throw _privateConstructorUsedError;
  List<double> get predictionUpper => throw _privateConstructorUsedError;
  List<double> get confidenceLower => throw _privateConstructorUsedError;
  List<double> get confidenceUpper => throw _privateConstructorUsedError;

  /// Serializes this Intervals to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Intervals
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IntervalsCopyWith<Intervals> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IntervalsCopyWith<$Res> {
  factory $IntervalsCopyWith(Intervals value, $Res Function(Intervals) then) =
      _$IntervalsCopyWithImpl<$Res, Intervals>;
  @useResult
  $Res call(
      {List<double> y,
      List<double> yHat,
      List<double> predictionLower,
      List<double> predictionUpper,
      List<double> confidenceLower,
      List<double> confidenceUpper});
}

/// @nodoc
class _$IntervalsCopyWithImpl<$Res, $Val extends Intervals>
    implements $IntervalsCopyWith<$Res> {
  _$IntervalsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Intervals
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? y = null,
    Object? yHat = null,
    Object? predictionLower = null,
    Object? predictionUpper = null,
    Object? confidenceLower = null,
    Object? confidenceUpper = null,
  }) {
    return _then(_value.copyWith(
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as List<double>,
      yHat: null == yHat
          ? _value.yHat
          : yHat // ignore: cast_nullable_to_non_nullable
              as List<double>,
      predictionLower: null == predictionLower
          ? _value.predictionLower
          : predictionLower // ignore: cast_nullable_to_non_nullable
              as List<double>,
      predictionUpper: null == predictionUpper
          ? _value.predictionUpper
          : predictionUpper // ignore: cast_nullable_to_non_nullable
              as List<double>,
      confidenceLower: null == confidenceLower
          ? _value.confidenceLower
          : confidenceLower // ignore: cast_nullable_to_non_nullable
              as List<double>,
      confidenceUpper: null == confidenceUpper
          ? _value.confidenceUpper
          : confidenceUpper // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IntervalsImplCopyWith<$Res>
    implements $IntervalsCopyWith<$Res> {
  factory _$$IntervalsImplCopyWith(
          _$IntervalsImpl value, $Res Function(_$IntervalsImpl) then) =
      __$$IntervalsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<double> y,
      List<double> yHat,
      List<double> predictionLower,
      List<double> predictionUpper,
      List<double> confidenceLower,
      List<double> confidenceUpper});
}

/// @nodoc
class __$$IntervalsImplCopyWithImpl<$Res>
    extends _$IntervalsCopyWithImpl<$Res, _$IntervalsImpl>
    implements _$$IntervalsImplCopyWith<$Res> {
  __$$IntervalsImplCopyWithImpl(
      _$IntervalsImpl _value, $Res Function(_$IntervalsImpl) _then)
      : super(_value, _then);

  /// Create a copy of Intervals
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? y = null,
    Object? yHat = null,
    Object? predictionLower = null,
    Object? predictionUpper = null,
    Object? confidenceLower = null,
    Object? confidenceUpper = null,
  }) {
    return _then(_$IntervalsImpl(
      y: null == y
          ? _value._y
          : y // ignore: cast_nullable_to_non_nullable
              as List<double>,
      yHat: null == yHat
          ? _value._yHat
          : yHat // ignore: cast_nullable_to_non_nullable
              as List<double>,
      predictionLower: null == predictionLower
          ? _value._predictionLower
          : predictionLower // ignore: cast_nullable_to_non_nullable
              as List<double>,
      predictionUpper: null == predictionUpper
          ? _value._predictionUpper
          : predictionUpper // ignore: cast_nullable_to_non_nullable
              as List<double>,
      confidenceLower: null == confidenceLower
          ? _value._confidenceLower
          : confidenceLower // ignore: cast_nullable_to_non_nullable
              as List<double>,
      confidenceUpper: null == confidenceUpper
          ? _value._confidenceUpper
          : confidenceUpper // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IntervalsImpl implements _Intervals {
  const _$IntervalsImpl(
      {required final List<double> y,
      required final List<double> yHat,
      required final List<double> predictionLower,
      required final List<double> predictionUpper,
      required final List<double> confidenceLower,
      required final List<double> confidenceUpper})
      : _y = y,
        _yHat = yHat,
        _predictionLower = predictionLower,
        _predictionUpper = predictionUpper,
        _confidenceLower = confidenceLower,
        _confidenceUpper = confidenceUpper;

  factory _$IntervalsImpl.fromJson(Map<String, dynamic> json) =>
      _$$IntervalsImplFromJson(json);

  final List<double> _y;
  @override
  List<double> get y {
    if (_y is EqualUnmodifiableListView) return _y;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_y);
  }

  final List<double> _yHat;
  @override
  List<double> get yHat {
    if (_yHat is EqualUnmodifiableListView) return _yHat;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_yHat);
  }

  final List<double> _predictionLower;
  @override
  List<double> get predictionLower {
    if (_predictionLower is EqualUnmodifiableListView) return _predictionLower;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_predictionLower);
  }

  final List<double> _predictionUpper;
  @override
  List<double> get predictionUpper {
    if (_predictionUpper is EqualUnmodifiableListView) return _predictionUpper;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_predictionUpper);
  }

  final List<double> _confidenceLower;
  @override
  List<double> get confidenceLower {
    if (_confidenceLower is EqualUnmodifiableListView) return _confidenceLower;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_confidenceLower);
  }

  final List<double> _confidenceUpper;
  @override
  List<double> get confidenceUpper {
    if (_confidenceUpper is EqualUnmodifiableListView) return _confidenceUpper;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_confidenceUpper);
  }

  @override
  String toString() {
    return 'Intervals(y: $y, yHat: $yHat, predictionLower: $predictionLower, predictionUpper: $predictionUpper, confidenceLower: $confidenceLower, confidenceUpper: $confidenceUpper)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IntervalsImpl &&
            const DeepCollectionEquality().equals(other._y, _y) &&
            const DeepCollectionEquality().equals(other._yHat, _yHat) &&
            const DeepCollectionEquality()
                .equals(other._predictionLower, _predictionLower) &&
            const DeepCollectionEquality()
                .equals(other._predictionUpper, _predictionUpper) &&
            const DeepCollectionEquality()
                .equals(other._confidenceLower, _confidenceLower) &&
            const DeepCollectionEquality()
                .equals(other._confidenceUpper, _confidenceUpper));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_y),
      const DeepCollectionEquality().hash(_yHat),
      const DeepCollectionEquality().hash(_predictionLower),
      const DeepCollectionEquality().hash(_predictionUpper),
      const DeepCollectionEquality().hash(_confidenceLower),
      const DeepCollectionEquality().hash(_confidenceUpper));

  /// Create a copy of Intervals
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IntervalsImplCopyWith<_$IntervalsImpl> get copyWith =>
      __$$IntervalsImplCopyWithImpl<_$IntervalsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IntervalsImplToJson(
      this,
    );
  }
}

abstract class _Intervals implements Intervals {
  const factory _Intervals(
      {required final List<double> y,
      required final List<double> yHat,
      required final List<double> predictionLower,
      required final List<double> predictionUpper,
      required final List<double> confidenceLower,
      required final List<double> confidenceUpper}) = _$IntervalsImpl;

  factory _Intervals.fromJson(Map<String, dynamic> json) =
      _$IntervalsImpl.fromJson;

  @override
  List<double> get y;
  @override
  List<double> get yHat;
  @override
  List<double> get predictionLower;
  @override
  List<double> get predictionUpper;
  @override
  List<double> get confidenceLower;
  @override
  List<double> get confidenceUpper;

  /// Create a copy of Intervals
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IntervalsImplCopyWith<_$IntervalsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

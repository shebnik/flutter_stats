// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model_quality.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ModelQuality _$ModelQualityFromJson(Map<String, dynamic> json) {
  return _ModelQuality.fromJson(json);
}

/// @nodoc
mixin _$ModelQuality {
  double get rSquared => throw _privateConstructorUsedError;
  double get mmre => throw _privateConstructorUsedError;
  double get pred => throw _privateConstructorUsedError;

  /// Serializes this ModelQuality to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModelQuality
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModelQualityCopyWith<ModelQuality> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModelQualityCopyWith<$Res> {
  factory $ModelQualityCopyWith(
          ModelQuality value, $Res Function(ModelQuality) then) =
      _$ModelQualityCopyWithImpl<$Res, ModelQuality>;
  @useResult
  $Res call({double rSquared, double mmre, double pred});
}

/// @nodoc
class _$ModelQualityCopyWithImpl<$Res, $Val extends ModelQuality>
    implements $ModelQualityCopyWith<$Res> {
  _$ModelQualityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModelQuality
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rSquared = null,
    Object? mmre = null,
    Object? pred = null,
  }) {
    return _then(_value.copyWith(
      rSquared: null == rSquared
          ? _value.rSquared
          : rSquared // ignore: cast_nullable_to_non_nullable
              as double,
      mmre: null == mmre
          ? _value.mmre
          : mmre // ignore: cast_nullable_to_non_nullable
              as double,
      pred: null == pred
          ? _value.pred
          : pred // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModelQualityImplCopyWith<$Res>
    implements $ModelQualityCopyWith<$Res> {
  factory _$$ModelQualityImplCopyWith(
          _$ModelQualityImpl value, $Res Function(_$ModelQualityImpl) then) =
      __$$ModelQualityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double rSquared, double mmre, double pred});
}

/// @nodoc
class __$$ModelQualityImplCopyWithImpl<$Res>
    extends _$ModelQualityCopyWithImpl<$Res, _$ModelQualityImpl>
    implements _$$ModelQualityImplCopyWith<$Res> {
  __$$ModelQualityImplCopyWithImpl(
      _$ModelQualityImpl _value, $Res Function(_$ModelQualityImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModelQuality
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rSquared = null,
    Object? mmre = null,
    Object? pred = null,
  }) {
    return _then(_$ModelQualityImpl(
      rSquared: null == rSquared
          ? _value.rSquared
          : rSquared // ignore: cast_nullable_to_non_nullable
              as double,
      mmre: null == mmre
          ? _value.mmre
          : mmre // ignore: cast_nullable_to_non_nullable
              as double,
      pred: null == pred
          ? _value.pred
          : pred // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModelQualityImpl implements _ModelQuality {
  const _$ModelQualityImpl(
      {required this.rSquared, required this.mmre, required this.pred});

  factory _$ModelQualityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModelQualityImplFromJson(json);

  @override
  final double rSquared;
  @override
  final double mmre;
  @override
  final double pred;

  @override
  String toString() {
    return 'ModelQuality(rSquared: $rSquared, mmre: $mmre, pred: $pred)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelQualityImpl &&
            (identical(other.rSquared, rSquared) ||
                other.rSquared == rSquared) &&
            (identical(other.mmre, mmre) || other.mmre == mmre) &&
            (identical(other.pred, pred) || other.pred == pred));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rSquared, mmre, pred);

  /// Create a copy of ModelQuality
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModelQualityImplCopyWith<_$ModelQualityImpl> get copyWith =>
      __$$ModelQualityImplCopyWithImpl<_$ModelQualityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModelQualityImplToJson(
      this,
    );
  }
}

abstract class _ModelQuality implements ModelQuality {
  const factory _ModelQuality(
      {required final double rSquared,
      required final double mmre,
      required final double pred}) = _$ModelQualityImpl;

  factory _ModelQuality.fromJson(Map<String, dynamic> json) =
      _$ModelQualityImpl.fromJson;

  @override
  double get rSquared;
  @override
  double get mmre;
  @override
  double get pred;

  /// Create a copy of ModelQuality
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModelQualityImplCopyWith<_$ModelQualityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dataset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Dataset _$DatasetFromJson(Map<String, dynamic> json) {
  return _Dataset.fromJson(json);
}

/// @nodoc
mixin _$Dataset {
  @Uint8ListConverter()
  Uint8List get data => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;

  /// Serializes this Dataset to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Dataset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DatasetCopyWith<Dataset> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DatasetCopyWith<$Res> {
  factory $DatasetCopyWith(Dataset value, $Res Function(Dataset) then) =
      _$DatasetCopyWithImpl<$Res, Dataset>;
  @useResult
  $Res call({@Uint8ListConverter() Uint8List data, String? name});
}

/// @nodoc
class _$DatasetCopyWithImpl<$Res, $Val extends Dataset>
    implements $DatasetCopyWith<$Res> {
  _$DatasetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Dataset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? name = freezed,
  }) {
    return _then(_value.copyWith(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DatasetImplCopyWith<$Res> implements $DatasetCopyWith<$Res> {
  factory _$$DatasetImplCopyWith(
          _$DatasetImpl value, $Res Function(_$DatasetImpl) then) =
      __$$DatasetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@Uint8ListConverter() Uint8List data, String? name});
}

/// @nodoc
class __$$DatasetImplCopyWithImpl<$Res>
    extends _$DatasetCopyWithImpl<$Res, _$DatasetImpl>
    implements _$$DatasetImplCopyWith<$Res> {
  __$$DatasetImplCopyWithImpl(
      _$DatasetImpl _value, $Res Function(_$DatasetImpl) _then)
      : super(_value, _then);

  /// Create a copy of Dataset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? name = freezed,
  }) {
    return _then(_$DatasetImpl(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DatasetImpl implements _Dataset {
  const _$DatasetImpl({@Uint8ListConverter() required this.data, this.name});

  factory _$DatasetImpl.fromJson(Map<String, dynamic> json) =>
      _$$DatasetImplFromJson(json);

  @override
  @Uint8ListConverter()
  final Uint8List data;
  @override
  final String? name;

  @override
  String toString() {
    return 'Dataset(data: $data, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DatasetImpl &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data), name);

  /// Create a copy of Dataset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DatasetImplCopyWith<_$DatasetImpl> get copyWith =>
      __$$DatasetImplCopyWithImpl<_$DatasetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DatasetImplToJson(
      this,
    );
  }
}

abstract class _Dataset implements Dataset {
  const factory _Dataset(
      {@Uint8ListConverter() required final Uint8List data,
      final String? name}) = _$DatasetImpl;

  factory _Dataset.fromJson(Map<String, dynamic> json) = _$DatasetImpl.fromJson;

  @override
  @Uint8ListConverter()
  Uint8List get data;
  @override
  String? get name;

  /// Create a copy of Dataset
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DatasetImplCopyWith<_$DatasetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

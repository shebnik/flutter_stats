// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'csv_alias.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CSVAlias _$CSVAliasFromJson(Map<String, dynamic> json) {
  return _CSVAlias.fromJson(json);
}

/// @nodoc
mixin _$CSVAlias {
  String get y => throw _privateConstructorUsedError;
  String get x1 => throw _privateConstructorUsedError;
  String get x2 => throw _privateConstructorUsedError;
  String get x3 => throw _privateConstructorUsedError;
  String get noc => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;

  /// Serializes this CSVAlias to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CSVAlias
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CSVAliasCopyWith<CSVAlias> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CSVAliasCopyWith<$Res> {
  factory $CSVAliasCopyWith(CSVAlias value, $Res Function(CSVAlias) then) =
      _$CSVAliasCopyWithImpl<$Res, CSVAlias>;
  @useResult
  $Res call(
      {String y, String x1, String x2, String x3, String noc, String url});
}

/// @nodoc
class _$CSVAliasCopyWithImpl<$Res, $Val extends CSVAlias>
    implements $CSVAliasCopyWith<$Res> {
  _$CSVAliasCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CSVAlias
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? y = null,
    Object? x1 = null,
    Object? x2 = null,
    Object? x3 = null,
    Object? noc = null,
    Object? url = null,
  }) {
    return _then(_value.copyWith(
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as String,
      x1: null == x1
          ? _value.x1
          : x1 // ignore: cast_nullable_to_non_nullable
              as String,
      x2: null == x2
          ? _value.x2
          : x2 // ignore: cast_nullable_to_non_nullable
              as String,
      x3: null == x3
          ? _value.x3
          : x3 // ignore: cast_nullable_to_non_nullable
              as String,
      noc: null == noc
          ? _value.noc
          : noc // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CSVAliasImplCopyWith<$Res>
    implements $CSVAliasCopyWith<$Res> {
  factory _$$CSVAliasImplCopyWith(
          _$CSVAliasImpl value, $Res Function(_$CSVAliasImpl) then) =
      __$$CSVAliasImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String y, String x1, String x2, String x3, String noc, String url});
}

/// @nodoc
class __$$CSVAliasImplCopyWithImpl<$Res>
    extends _$CSVAliasCopyWithImpl<$Res, _$CSVAliasImpl>
    implements _$$CSVAliasImplCopyWith<$Res> {
  __$$CSVAliasImplCopyWithImpl(
      _$CSVAliasImpl _value, $Res Function(_$CSVAliasImpl) _then)
      : super(_value, _then);

  /// Create a copy of CSVAlias
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? y = null,
    Object? x1 = null,
    Object? x2 = null,
    Object? x3 = null,
    Object? noc = null,
    Object? url = null,
  }) {
    return _then(_$CSVAliasImpl(
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as String,
      x1: null == x1
          ? _value.x1
          : x1 // ignore: cast_nullable_to_non_nullable
              as String,
      x2: null == x2
          ? _value.x2
          : x2 // ignore: cast_nullable_to_non_nullable
              as String,
      x3: null == x3
          ? _value.x3
          : x3 // ignore: cast_nullable_to_non_nullable
              as String,
      noc: null == noc
          ? _value.noc
          : noc // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CSVAliasImpl extends _CSVAlias {
  const _$CSVAliasImpl(
      {this.y = 'RFC',
      this.x1 = 'DIT',
      this.x2 = 'CBO',
      this.x3 = 'WMC',
      this.noc = 'NOC',
      this.url = 'URL'})
      : super._();

  factory _$CSVAliasImpl.fromJson(Map<String, dynamic> json) =>
      _$$CSVAliasImplFromJson(json);

  @override
  @JsonKey()
  final String y;
  @override
  @JsonKey()
  final String x1;
  @override
  @JsonKey()
  final String x2;
  @override
  @JsonKey()
  final String x3;
  @override
  @JsonKey()
  final String noc;
  @override
  @JsonKey()
  final String url;

  @override
  String toString() {
    return 'CSVAlias(y: $y, x1: $x1, x2: $x2, x3: $x3, noc: $noc, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CSVAliasImpl &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.x1, x1) || other.x1 == x1) &&
            (identical(other.x2, x2) || other.x2 == x2) &&
            (identical(other.x3, x3) || other.x3 == x3) &&
            (identical(other.noc, noc) || other.noc == noc) &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, y, x1, x2, x3, noc, url);

  /// Create a copy of CSVAlias
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CSVAliasImplCopyWith<_$CSVAliasImpl> get copyWith =>
      __$$CSVAliasImplCopyWithImpl<_$CSVAliasImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CSVAliasImplToJson(
      this,
    );
  }
}

abstract class _CSVAlias extends CSVAlias {
  const factory _CSVAlias(
      {final String y,
      final String x1,
      final String x2,
      final String x3,
      final String noc,
      final String url}) = _$CSVAliasImpl;
  const _CSVAlias._() : super._();

  factory _CSVAlias.fromJson(Map<String, dynamic> json) =
      _$CSVAliasImpl.fromJson;

  @override
  String get y;
  @override
  String get x1;
  @override
  String get x2;
  @override
  String get x3;
  @override
  String get noc;
  @override
  String get url;

  /// Create a copy of CSVAlias
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CSVAliasImplCopyWith<_$CSVAliasImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

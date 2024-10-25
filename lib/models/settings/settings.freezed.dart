// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Settings _$SettingsFromJson(Map<String, dynamic> json) {
  return _Settings.fromJson(json);
}

/// @nodoc
mixin _$Settings {
  bool get useRelativeNOC => throw _privateConstructorUsedError;
  bool get useSigma => throw _privateConstructorUsedError;
  bool get useX2 => throw _privateConstructorUsedError;
  bool get useX3 => throw _privateConstructorUsedError;
  CSVAlias get csvAlias => throw _privateConstructorUsedError;

  /// Serializes this Settings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettingsCopyWith<Settings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsCopyWith<$Res> {
  factory $SettingsCopyWith(Settings value, $Res Function(Settings) then) =
      _$SettingsCopyWithImpl<$Res, Settings>;
  @useResult
  $Res call(
      {bool useRelativeNOC,
      bool useSigma,
      bool useX2,
      bool useX3,
      CSVAlias csvAlias});

  $CSVAliasCopyWith<$Res> get csvAlias;
}

/// @nodoc
class _$SettingsCopyWithImpl<$Res, $Val extends Settings>
    implements $SettingsCopyWith<$Res> {
  _$SettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? useRelativeNOC = null,
    Object? useSigma = null,
    Object? useX2 = null,
    Object? useX3 = null,
    Object? csvAlias = null,
  }) {
    return _then(_value.copyWith(
      useRelativeNOC: null == useRelativeNOC
          ? _value.useRelativeNOC
          : useRelativeNOC // ignore: cast_nullable_to_non_nullable
              as bool,
      useSigma: null == useSigma
          ? _value.useSigma
          : useSigma // ignore: cast_nullable_to_non_nullable
              as bool,
      useX2: null == useX2
          ? _value.useX2
          : useX2 // ignore: cast_nullable_to_non_nullable
              as bool,
      useX3: null == useX3
          ? _value.useX3
          : useX3 // ignore: cast_nullable_to_non_nullable
              as bool,
      csvAlias: null == csvAlias
          ? _value.csvAlias
          : csvAlias // ignore: cast_nullable_to_non_nullable
              as CSVAlias,
    ) as $Val);
  }

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CSVAliasCopyWith<$Res> get csvAlias {
    return $CSVAliasCopyWith<$Res>(_value.csvAlias, (value) {
      return _then(_value.copyWith(csvAlias: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SettingsImplCopyWith<$Res>
    implements $SettingsCopyWith<$Res> {
  factory _$$SettingsImplCopyWith(
          _$SettingsImpl value, $Res Function(_$SettingsImpl) then) =
      __$$SettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool useRelativeNOC,
      bool useSigma,
      bool useX2,
      bool useX3,
      CSVAlias csvAlias});

  @override
  $CSVAliasCopyWith<$Res> get csvAlias;
}

/// @nodoc
class __$$SettingsImplCopyWithImpl<$Res>
    extends _$SettingsCopyWithImpl<$Res, _$SettingsImpl>
    implements _$$SettingsImplCopyWith<$Res> {
  __$$SettingsImplCopyWithImpl(
      _$SettingsImpl _value, $Res Function(_$SettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? useRelativeNOC = null,
    Object? useSigma = null,
    Object? useX2 = null,
    Object? useX3 = null,
    Object? csvAlias = null,
  }) {
    return _then(_$SettingsImpl(
      useRelativeNOC: null == useRelativeNOC
          ? _value.useRelativeNOC
          : useRelativeNOC // ignore: cast_nullable_to_non_nullable
              as bool,
      useSigma: null == useSigma
          ? _value.useSigma
          : useSigma // ignore: cast_nullable_to_non_nullable
              as bool,
      useX2: null == useX2
          ? _value.useX2
          : useX2 // ignore: cast_nullable_to_non_nullable
              as bool,
      useX3: null == useX3
          ? _value.useX3
          : useX3 // ignore: cast_nullable_to_non_nullable
              as bool,
      csvAlias: null == csvAlias
          ? _value.csvAlias
          : csvAlias // ignore: cast_nullable_to_non_nullable
              as CSVAlias,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$SettingsImpl implements _Settings {
  const _$SettingsImpl(
      {this.useRelativeNOC = false,
      this.useSigma = false,
      this.useX2 = true,
      this.useX3 = true,
      this.csvAlias = CSVAlias.defaultAlias});

  factory _$SettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettingsImplFromJson(json);

  @override
  @JsonKey()
  final bool useRelativeNOC;
  @override
  @JsonKey()
  final bool useSigma;
  @override
  @JsonKey()
  final bool useX2;
  @override
  @JsonKey()
  final bool useX3;
  @override
  @JsonKey()
  final CSVAlias csvAlias;

  @override
  String toString() {
    return 'Settings(useRelativeNOC: $useRelativeNOC, useSigma: $useSigma, useX2: $useX2, useX3: $useX3, csvAlias: $csvAlias)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsImpl &&
            (identical(other.useRelativeNOC, useRelativeNOC) ||
                other.useRelativeNOC == useRelativeNOC) &&
            (identical(other.useSigma, useSigma) ||
                other.useSigma == useSigma) &&
            (identical(other.useX2, useX2) || other.useX2 == useX2) &&
            (identical(other.useX3, useX3) || other.useX3 == useX3) &&
            (identical(other.csvAlias, csvAlias) ||
                other.csvAlias == csvAlias));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, useRelativeNOC, useSigma, useX2, useX3, csvAlias);

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsImplCopyWith<_$SettingsImpl> get copyWith =>
      __$$SettingsImplCopyWithImpl<_$SettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SettingsImplToJson(
      this,
    );
  }
}

abstract class _Settings implements Settings {
  const factory _Settings(
      {final bool useRelativeNOC,
      final bool useSigma,
      final bool useX2,
      final bool useX3,
      final CSVAlias csvAlias}) = _$SettingsImpl;

  factory _Settings.fromJson(Map<String, dynamic> json) =
      _$SettingsImpl.fromJson;

  @override
  bool get useRelativeNOC;
  @override
  bool get useSigma;
  @override
  bool get useX2;
  @override
  bool get useX3;
  @override
  CSVAlias get csvAlias;

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettingsImplCopyWith<_$SettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

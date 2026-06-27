// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_payout_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DriverPayoutLog _$DriverPayoutLogFromJson(Map<String, dynamic> json) {
  return _DriverPayoutLog.fromJson(json);
}

/// @nodoc
mixin _$DriverPayoutLog {
  String get id => throw _privateConstructorUsedError;
  String get driverId => throw _privateConstructorUsedError;
  String get supplierId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  double get deductions => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DriverPayoutLogCopyWith<DriverPayoutLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverPayoutLogCopyWith<$Res> {
  factory $DriverPayoutLogCopyWith(
          DriverPayoutLog value, $Res Function(DriverPayoutLog) then) =
      _$DriverPayoutLogCopyWithImpl<$Res, DriverPayoutLog>;
  @useResult
  $Res call(
      {String id,
      String driverId,
      String supplierId,
      double amount,
      double deductions,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class _$DriverPayoutLogCopyWithImpl<$Res, $Val extends DriverPayoutLog>
    implements $DriverPayoutLogCopyWith<$Res> {
  _$DriverPayoutLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverId = null,
    Object? supplierId = null,
    Object? amount = null,
    Object? deductions = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      supplierId: null == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      deductions: null == deductions
          ? _value.deductions
          : deductions // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverPayoutLogImplCopyWith<$Res>
    implements $DriverPayoutLogCopyWith<$Res> {
  factory _$$DriverPayoutLogImplCopyWith(_$DriverPayoutLogImpl value,
          $Res Function(_$DriverPayoutLogImpl) then) =
      __$$DriverPayoutLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String driverId,
      String supplierId,
      double amount,
      double deductions,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class __$$DriverPayoutLogImplCopyWithImpl<$Res>
    extends _$DriverPayoutLogCopyWithImpl<$Res, _$DriverPayoutLogImpl>
    implements _$$DriverPayoutLogImplCopyWith<$Res> {
  __$$DriverPayoutLogImplCopyWithImpl(
      _$DriverPayoutLogImpl _value, $Res Function(_$DriverPayoutLogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverId = null,
    Object? supplierId = null,
    Object? amount = null,
    Object? deductions = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$DriverPayoutLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      supplierId: null == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      deductions: null == deductions
          ? _value.deductions
          : deductions // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverPayoutLogImpl implements _DriverPayoutLog {
  const _$DriverPayoutLogImpl(
      {required this.id,
      required this.driverId,
      required this.supplierId,
      this.amount = 0,
      this.deductions = 0,
      this.notes,
      required this.createdAt});

  factory _$DriverPayoutLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverPayoutLogImplFromJson(json);

  @override
  final String id;
  @override
  final String driverId;
  @override
  final String supplierId;
  @override
  @JsonKey()
  final double amount;
  @override
  @JsonKey()
  final double deductions;
  @override
  final String? notes;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'DriverPayoutLog(id: $id, driverId: $driverId, supplierId: $supplierId, amount: $amount, deductions: $deductions, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverPayoutLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.deductions, deductions) ||
                other.deductions == deductions) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, driverId, supplierId, amount,
      deductions, notes, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverPayoutLogImplCopyWith<_$DriverPayoutLogImpl> get copyWith =>
      __$$DriverPayoutLogImplCopyWithImpl<_$DriverPayoutLogImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverPayoutLogImplToJson(
      this,
    );
  }
}

abstract class _DriverPayoutLog implements DriverPayoutLog {
  const factory _DriverPayoutLog(
      {required final String id,
      required final String driverId,
      required final String supplierId,
      final double amount,
      final double deductions,
      final String? notes,
      required final DateTime createdAt}) = _$DriverPayoutLogImpl;

  factory _DriverPayoutLog.fromJson(Map<String, dynamic> json) =
      _$DriverPayoutLogImpl.fromJson;

  @override
  String get id;
  @override
  String get driverId;
  @override
  String get supplierId;
  @override
  double get amount;
  @override
  double get deductions;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$DriverPayoutLogImplCopyWith<_$DriverPayoutLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

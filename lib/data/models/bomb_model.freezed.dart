// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bomb_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BombModel {

 String get id; String get groupId; String get holderUid;// 현재 폭탄 보유자
 DateTime get receivedAt;// 받은 시각
 DateTime get expiresAt;// 만료 시각
 BombStatus get status; int get round;// 몇 번째 라운드
 String? get explodedUid;
/// Create a copy of BombModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BombModelCopyWith<BombModel> get copyWith => _$BombModelCopyWithImpl<BombModel>(this as BombModel, _$identity);

  /// Serializes this BombModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BombModel&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.holderUid, holderUid) || other.holderUid == holderUid)&&(identical(other.receivedAt, receivedAt) || other.receivedAt == receivedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.round, round) || other.round == round)&&(identical(other.explodedUid, explodedUid) || other.explodedUid == explodedUid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,holderUid,receivedAt,expiresAt,status,round,explodedUid);

@override
String toString() {
  return 'BombModel(id: $id, groupId: $groupId, holderUid: $holderUid, receivedAt: $receivedAt, expiresAt: $expiresAt, status: $status, round: $round, explodedUid: $explodedUid)';
}


}

/// @nodoc
abstract mixin class $BombModelCopyWith<$Res>  {
  factory $BombModelCopyWith(BombModel value, $Res Function(BombModel) _then) = _$BombModelCopyWithImpl;
@useResult
$Res call({
 String id, String groupId, String holderUid, DateTime receivedAt, DateTime expiresAt, BombStatus status, int round, String? explodedUid
});




}
/// @nodoc
class _$BombModelCopyWithImpl<$Res>
    implements $BombModelCopyWith<$Res> {
  _$BombModelCopyWithImpl(this._self, this._then);

  final BombModel _self;
  final $Res Function(BombModel) _then;

/// Create a copy of BombModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupId = null,Object? holderUid = null,Object? receivedAt = null,Object? expiresAt = null,Object? status = null,Object? round = null,Object? explodedUid = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,holderUid: null == holderUid ? _self.holderUid : holderUid // ignore: cast_nullable_to_non_nullable
as String,receivedAt: null == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BombStatus,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as int,explodedUid: freezed == explodedUid ? _self.explodedUid : explodedUid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BombModel].
extension BombModelPatterns on BombModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BombModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BombModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BombModel value)  $default,){
final _that = this;
switch (_that) {
case _BombModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BombModel value)?  $default,){
final _that = this;
switch (_that) {
case _BombModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String groupId,  String holderUid,  DateTime receivedAt,  DateTime expiresAt,  BombStatus status,  int round,  String? explodedUid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BombModel() when $default != null:
return $default(_that.id,_that.groupId,_that.holderUid,_that.receivedAt,_that.expiresAt,_that.status,_that.round,_that.explodedUid);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String groupId,  String holderUid,  DateTime receivedAt,  DateTime expiresAt,  BombStatus status,  int round,  String? explodedUid)  $default,) {final _that = this;
switch (_that) {
case _BombModel():
return $default(_that.id,_that.groupId,_that.holderUid,_that.receivedAt,_that.expiresAt,_that.status,_that.round,_that.explodedUid);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String groupId,  String holderUid,  DateTime receivedAt,  DateTime expiresAt,  BombStatus status,  int round,  String? explodedUid)?  $default,) {final _that = this;
switch (_that) {
case _BombModel() when $default != null:
return $default(_that.id,_that.groupId,_that.holderUid,_that.receivedAt,_that.expiresAt,_that.status,_that.round,_that.explodedUid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BombModel implements BombModel {
  const _BombModel({required this.id, required this.groupId, required this.holderUid, required this.receivedAt, required this.expiresAt, required this.status, this.round = 0, this.explodedUid});
  factory _BombModel.fromJson(Map<String, dynamic> json) => _$BombModelFromJson(json);

@override final  String id;
@override final  String groupId;
@override final  String holderUid;
// 현재 폭탄 보유자
@override final  DateTime receivedAt;
// 받은 시각
@override final  DateTime expiresAt;
// 만료 시각
@override final  BombStatus status;
@override@JsonKey() final  int round;
// 몇 번째 라운드
@override final  String? explodedUid;

/// Create a copy of BombModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BombModelCopyWith<_BombModel> get copyWith => __$BombModelCopyWithImpl<_BombModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BombModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BombModel&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.holderUid, holderUid) || other.holderUid == holderUid)&&(identical(other.receivedAt, receivedAt) || other.receivedAt == receivedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.round, round) || other.round == round)&&(identical(other.explodedUid, explodedUid) || other.explodedUid == explodedUid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,holderUid,receivedAt,expiresAt,status,round,explodedUid);

@override
String toString() {
  return 'BombModel(id: $id, groupId: $groupId, holderUid: $holderUid, receivedAt: $receivedAt, expiresAt: $expiresAt, status: $status, round: $round, explodedUid: $explodedUid)';
}


}

/// @nodoc
abstract mixin class _$BombModelCopyWith<$Res> implements $BombModelCopyWith<$Res> {
  factory _$BombModelCopyWith(_BombModel value, $Res Function(_BombModel) _then) = __$BombModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String groupId, String holderUid, DateTime receivedAt, DateTime expiresAt, BombStatus status, int round, String? explodedUid
});




}
/// @nodoc
class __$BombModelCopyWithImpl<$Res>
    implements _$BombModelCopyWith<$Res> {
  __$BombModelCopyWithImpl(this._self, this._then);

  final _BombModel _self;
  final $Res Function(_BombModel) _then;

/// Create a copy of BombModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupId = null,Object? holderUid = null,Object? receivedAt = null,Object? expiresAt = null,Object? status = null,Object? round = null,Object? explodedUid = freezed,}) {
  return _then(_BombModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,holderUid: null == holderUid ? _self.holderUid : holderUid // ignore: cast_nullable_to_non_nullable
as String,receivedAt: null == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BombStatus,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as int,explodedUid: freezed == explodedUid ? _self.explodedUid : explodedUid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayerResultModel {

 String get uid; String get displayName; int get explodeCount; int get passCount; int get maxHoldingMinutes;// 최장 홀딩 시간 (분)
 int get itemUsedCount;
/// Create a copy of PlayerResultModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerResultModelCopyWith<PlayerResultModel> get copyWith => _$PlayerResultModelCopyWithImpl<PlayerResultModel>(this as PlayerResultModel, _$identity);

  /// Serializes this PlayerResultModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerResultModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.explodeCount, explodeCount) || other.explodeCount == explodeCount)&&(identical(other.passCount, passCount) || other.passCount == passCount)&&(identical(other.maxHoldingMinutes, maxHoldingMinutes) || other.maxHoldingMinutes == maxHoldingMinutes)&&(identical(other.itemUsedCount, itemUsedCount) || other.itemUsedCount == itemUsedCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,displayName,explodeCount,passCount,maxHoldingMinutes,itemUsedCount);

@override
String toString() {
  return 'PlayerResultModel(uid: $uid, displayName: $displayName, explodeCount: $explodeCount, passCount: $passCount, maxHoldingMinutes: $maxHoldingMinutes, itemUsedCount: $itemUsedCount)';
}


}

/// @nodoc
abstract mixin class $PlayerResultModelCopyWith<$Res>  {
  factory $PlayerResultModelCopyWith(PlayerResultModel value, $Res Function(PlayerResultModel) _then) = _$PlayerResultModelCopyWithImpl;
@useResult
$Res call({
 String uid, String displayName, int explodeCount, int passCount, int maxHoldingMinutes, int itemUsedCount
});




}
/// @nodoc
class _$PlayerResultModelCopyWithImpl<$Res>
    implements $PlayerResultModelCopyWith<$Res> {
  _$PlayerResultModelCopyWithImpl(this._self, this._then);

  final PlayerResultModel _self;
  final $Res Function(PlayerResultModel) _then;

/// Create a copy of PlayerResultModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? displayName = null,Object? explodeCount = null,Object? passCount = null,Object? maxHoldingMinutes = null,Object? itemUsedCount = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,explodeCount: null == explodeCount ? _self.explodeCount : explodeCount // ignore: cast_nullable_to_non_nullable
as int,passCount: null == passCount ? _self.passCount : passCount // ignore: cast_nullable_to_non_nullable
as int,maxHoldingMinutes: null == maxHoldingMinutes ? _self.maxHoldingMinutes : maxHoldingMinutes // ignore: cast_nullable_to_non_nullable
as int,itemUsedCount: null == itemUsedCount ? _self.itemUsedCount : itemUsedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerResultModel].
extension PlayerResultModelPatterns on PlayerResultModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerResultModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerResultModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerResultModel value)  $default,){
final _that = this;
switch (_that) {
case _PlayerResultModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerResultModel value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerResultModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String displayName,  int explodeCount,  int passCount,  int maxHoldingMinutes,  int itemUsedCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerResultModel() when $default != null:
return $default(_that.uid,_that.displayName,_that.explodeCount,_that.passCount,_that.maxHoldingMinutes,_that.itemUsedCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String displayName,  int explodeCount,  int passCount,  int maxHoldingMinutes,  int itemUsedCount)  $default,) {final _that = this;
switch (_that) {
case _PlayerResultModel():
return $default(_that.uid,_that.displayName,_that.explodeCount,_that.passCount,_that.maxHoldingMinutes,_that.itemUsedCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String displayName,  int explodeCount,  int passCount,  int maxHoldingMinutes,  int itemUsedCount)?  $default,) {final _that = this;
switch (_that) {
case _PlayerResultModel() when $default != null:
return $default(_that.uid,_that.displayName,_that.explodeCount,_that.passCount,_that.maxHoldingMinutes,_that.itemUsedCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayerResultModel implements PlayerResultModel {
  const _PlayerResultModel({required this.uid, required this.displayName, required this.explodeCount, required this.passCount, this.maxHoldingMinutes = 0, this.itemUsedCount = 0});
  factory _PlayerResultModel.fromJson(Map<String, dynamic> json) => _$PlayerResultModelFromJson(json);

@override final  String uid;
@override final  String displayName;
@override final  int explodeCount;
@override final  int passCount;
@override@JsonKey() final  int maxHoldingMinutes;
// 최장 홀딩 시간 (분)
@override@JsonKey() final  int itemUsedCount;

/// Create a copy of PlayerResultModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerResultModelCopyWith<_PlayerResultModel> get copyWith => __$PlayerResultModelCopyWithImpl<_PlayerResultModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerResultModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerResultModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.explodeCount, explodeCount) || other.explodeCount == explodeCount)&&(identical(other.passCount, passCount) || other.passCount == passCount)&&(identical(other.maxHoldingMinutes, maxHoldingMinutes) || other.maxHoldingMinutes == maxHoldingMinutes)&&(identical(other.itemUsedCount, itemUsedCount) || other.itemUsedCount == itemUsedCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,displayName,explodeCount,passCount,maxHoldingMinutes,itemUsedCount);

@override
String toString() {
  return 'PlayerResultModel(uid: $uid, displayName: $displayName, explodeCount: $explodeCount, passCount: $passCount, maxHoldingMinutes: $maxHoldingMinutes, itemUsedCount: $itemUsedCount)';
}


}

/// @nodoc
abstract mixin class _$PlayerResultModelCopyWith<$Res> implements $PlayerResultModelCopyWith<$Res> {
  factory _$PlayerResultModelCopyWith(_PlayerResultModel value, $Res Function(_PlayerResultModel) _then) = __$PlayerResultModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String displayName, int explodeCount, int passCount, int maxHoldingMinutes, int itemUsedCount
});




}
/// @nodoc
class __$PlayerResultModelCopyWithImpl<$Res>
    implements _$PlayerResultModelCopyWith<$Res> {
  __$PlayerResultModelCopyWithImpl(this._self, this._then);

  final _PlayerResultModel _self;
  final $Res Function(_PlayerResultModel) _then;

/// Create a copy of PlayerResultModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? displayName = null,Object? explodeCount = null,Object? passCount = null,Object? maxHoldingMinutes = null,Object? itemUsedCount = null,}) {
  return _then(_PlayerResultModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,explodeCount: null == explodeCount ? _self.explodeCount : explodeCount // ignore: cast_nullable_to_non_nullable
as int,passCount: null == passCount ? _self.passCount : passCount // ignore: cast_nullable_to_non_nullable
as int,maxHoldingMinutes: null == maxHoldingMinutes ? _self.maxHoldingMinutes : maxHoldingMinutes // ignore: cast_nullable_to_non_nullable
as int,itemUsedCount: null == itemUsedCount ? _self.itemUsedCount : itemUsedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$GameResultModel {

 String get groupId; List<PlayerResultModel> get rankList;// 폭발 횟수 오름차순 정렬
 DateTime get endedAt;
/// Create a copy of GameResultModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameResultModelCopyWith<GameResultModel> get copyWith => _$GameResultModelCopyWithImpl<GameResultModel>(this as GameResultModel, _$identity);

  /// Serializes this GameResultModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameResultModel&&(identical(other.groupId, groupId) || other.groupId == groupId)&&const DeepCollectionEquality().equals(other.rankList, rankList)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupId,const DeepCollectionEquality().hash(rankList),endedAt);

@override
String toString() {
  return 'GameResultModel(groupId: $groupId, rankList: $rankList, endedAt: $endedAt)';
}


}

/// @nodoc
abstract mixin class $GameResultModelCopyWith<$Res>  {
  factory $GameResultModelCopyWith(GameResultModel value, $Res Function(GameResultModel) _then) = _$GameResultModelCopyWithImpl;
@useResult
$Res call({
 String groupId, List<PlayerResultModel> rankList, DateTime endedAt
});




}
/// @nodoc
class _$GameResultModelCopyWithImpl<$Res>
    implements $GameResultModelCopyWith<$Res> {
  _$GameResultModelCopyWithImpl(this._self, this._then);

  final GameResultModel _self;
  final $Res Function(GameResultModel) _then;

/// Create a copy of GameResultModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupId = null,Object? rankList = null,Object? endedAt = null,}) {
  return _then(_self.copyWith(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,rankList: null == rankList ? _self.rankList : rankList // ignore: cast_nullable_to_non_nullable
as List<PlayerResultModel>,endedAt: null == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GameResultModel].
extension GameResultModelPatterns on GameResultModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameResultModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameResultModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameResultModel value)  $default,){
final _that = this;
switch (_that) {
case _GameResultModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameResultModel value)?  $default,){
final _that = this;
switch (_that) {
case _GameResultModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String groupId,  List<PlayerResultModel> rankList,  DateTime endedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameResultModel() when $default != null:
return $default(_that.groupId,_that.rankList,_that.endedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String groupId,  List<PlayerResultModel> rankList,  DateTime endedAt)  $default,) {final _that = this;
switch (_that) {
case _GameResultModel():
return $default(_that.groupId,_that.rankList,_that.endedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String groupId,  List<PlayerResultModel> rankList,  DateTime endedAt)?  $default,) {final _that = this;
switch (_that) {
case _GameResultModel() when $default != null:
return $default(_that.groupId,_that.rankList,_that.endedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameResultModel implements GameResultModel {
  const _GameResultModel({required this.groupId, required final  List<PlayerResultModel> rankList, required this.endedAt}): _rankList = rankList;
  factory _GameResultModel.fromJson(Map<String, dynamic> json) => _$GameResultModelFromJson(json);

@override final  String groupId;
 final  List<PlayerResultModel> _rankList;
@override List<PlayerResultModel> get rankList {
  if (_rankList is EqualUnmodifiableListView) return _rankList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rankList);
}

// 폭발 횟수 오름차순 정렬
@override final  DateTime endedAt;

/// Create a copy of GameResultModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameResultModelCopyWith<_GameResultModel> get copyWith => __$GameResultModelCopyWithImpl<_GameResultModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameResultModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameResultModel&&(identical(other.groupId, groupId) || other.groupId == groupId)&&const DeepCollectionEquality().equals(other._rankList, _rankList)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupId,const DeepCollectionEquality().hash(_rankList),endedAt);

@override
String toString() {
  return 'GameResultModel(groupId: $groupId, rankList: $rankList, endedAt: $endedAt)';
}


}

/// @nodoc
abstract mixin class _$GameResultModelCopyWith<$Res> implements $GameResultModelCopyWith<$Res> {
  factory _$GameResultModelCopyWith(_GameResultModel value, $Res Function(_GameResultModel) _then) = __$GameResultModelCopyWithImpl;
@override @useResult
$Res call({
 String groupId, List<PlayerResultModel> rankList, DateTime endedAt
});




}
/// @nodoc
class __$GameResultModelCopyWithImpl<$Res>
    implements _$GameResultModelCopyWith<$Res> {
  __$GameResultModelCopyWithImpl(this._self, this._then);

  final _GameResultModel _self;
  final $Res Function(_GameResultModel) _then;

/// Create a copy of GameResultModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupId = null,Object? rankList = null,Object? endedAt = null,}) {
  return _then(_GameResultModel(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,rankList: null == rankList ? _self._rankList : rankList // ignore: cast_nullable_to_non_nullable
as List<PlayerResultModel>,endedAt: null == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

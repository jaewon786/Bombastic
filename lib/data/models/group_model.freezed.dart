// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupModel {

 String get id; String get joinCode; List<String> get memberUids;// 고정 순서 (index = 전달 순서)
 GroupStatus get status; DateTime get createdAt; DateTime? get gameStartedAt; DateTime? get gameEndedAt;
/// Create a copy of GroupModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupModelCopyWith<GroupModel> get copyWith => _$GroupModelCopyWithImpl<GroupModel>(this as GroupModel, _$identity);

  /// Serializes this GroupModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupModel&&(identical(other.id, id) || other.id == id)&&(identical(other.joinCode, joinCode) || other.joinCode == joinCode)&&const DeepCollectionEquality().equals(other.memberUids, memberUids)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.gameStartedAt, gameStartedAt) || other.gameStartedAt == gameStartedAt)&&(identical(other.gameEndedAt, gameEndedAt) || other.gameEndedAt == gameEndedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,joinCode,const DeepCollectionEquality().hash(memberUids),status,createdAt,gameStartedAt,gameEndedAt);

@override
String toString() {
  return 'GroupModel(id: $id, joinCode: $joinCode, memberUids: $memberUids, status: $status, createdAt: $createdAt, gameStartedAt: $gameStartedAt, gameEndedAt: $gameEndedAt)';
}


}

/// @nodoc
abstract mixin class $GroupModelCopyWith<$Res>  {
  factory $GroupModelCopyWith(GroupModel value, $Res Function(GroupModel) _then) = _$GroupModelCopyWithImpl;
@useResult
$Res call({
 String id, String joinCode, List<String> memberUids, GroupStatus status, DateTime createdAt, DateTime? gameStartedAt, DateTime? gameEndedAt
});




}
/// @nodoc
class _$GroupModelCopyWithImpl<$Res>
    implements $GroupModelCopyWith<$Res> {
  _$GroupModelCopyWithImpl(this._self, this._then);

  final GroupModel _self;
  final $Res Function(GroupModel) _then;

/// Create a copy of GroupModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? joinCode = null,Object? memberUids = null,Object? status = null,Object? createdAt = null,Object? gameStartedAt = freezed,Object? gameEndedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,joinCode: null == joinCode ? _self.joinCode : joinCode // ignore: cast_nullable_to_non_nullable
as String,memberUids: null == memberUids ? _self.memberUids : memberUids // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GroupStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,gameStartedAt: freezed == gameStartedAt ? _self.gameStartedAt : gameStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,gameEndedAt: freezed == gameEndedAt ? _self.gameEndedAt : gameEndedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupModel].
extension GroupModelPatterns on GroupModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupModel value)  $default,){
final _that = this;
switch (_that) {
case _GroupModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupModel value)?  $default,){
final _that = this;
switch (_that) {
case _GroupModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String joinCode,  List<String> memberUids,  GroupStatus status,  DateTime createdAt,  DateTime? gameStartedAt,  DateTime? gameEndedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupModel() when $default != null:
return $default(_that.id,_that.joinCode,_that.memberUids,_that.status,_that.createdAt,_that.gameStartedAt,_that.gameEndedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String joinCode,  List<String> memberUids,  GroupStatus status,  DateTime createdAt,  DateTime? gameStartedAt,  DateTime? gameEndedAt)  $default,) {final _that = this;
switch (_that) {
case _GroupModel():
return $default(_that.id,_that.joinCode,_that.memberUids,_that.status,_that.createdAt,_that.gameStartedAt,_that.gameEndedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String joinCode,  List<String> memberUids,  GroupStatus status,  DateTime createdAt,  DateTime? gameStartedAt,  DateTime? gameEndedAt)?  $default,) {final _that = this;
switch (_that) {
case _GroupModel() when $default != null:
return $default(_that.id,_that.joinCode,_that.memberUids,_that.status,_that.createdAt,_that.gameStartedAt,_that.gameEndedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupModel implements GroupModel {
  const _GroupModel({required this.id, required this.joinCode, required final  List<String> memberUids, required this.status, required this.createdAt, this.gameStartedAt, this.gameEndedAt}): _memberUids = memberUids;
  factory _GroupModel.fromJson(Map<String, dynamic> json) => _$GroupModelFromJson(json);

@override final  String id;
@override final  String joinCode;
 final  List<String> _memberUids;
@override List<String> get memberUids {
  if (_memberUids is EqualUnmodifiableListView) return _memberUids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberUids);
}

// 고정 순서 (index = 전달 순서)
@override final  GroupStatus status;
@override final  DateTime createdAt;
@override final  DateTime? gameStartedAt;
@override final  DateTime? gameEndedAt;

/// Create a copy of GroupModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupModelCopyWith<_GroupModel> get copyWith => __$GroupModelCopyWithImpl<_GroupModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupModel&&(identical(other.id, id) || other.id == id)&&(identical(other.joinCode, joinCode) || other.joinCode == joinCode)&&const DeepCollectionEquality().equals(other._memberUids, _memberUids)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.gameStartedAt, gameStartedAt) || other.gameStartedAt == gameStartedAt)&&(identical(other.gameEndedAt, gameEndedAt) || other.gameEndedAt == gameEndedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,joinCode,const DeepCollectionEquality().hash(_memberUids),status,createdAt,gameStartedAt,gameEndedAt);

@override
String toString() {
  return 'GroupModel(id: $id, joinCode: $joinCode, memberUids: $memberUids, status: $status, createdAt: $createdAt, gameStartedAt: $gameStartedAt, gameEndedAt: $gameEndedAt)';
}


}

/// @nodoc
abstract mixin class _$GroupModelCopyWith<$Res> implements $GroupModelCopyWith<$Res> {
  factory _$GroupModelCopyWith(_GroupModel value, $Res Function(_GroupModel) _then) = __$GroupModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String joinCode, List<String> memberUids, GroupStatus status, DateTime createdAt, DateTime? gameStartedAt, DateTime? gameEndedAt
});




}
/// @nodoc
class __$GroupModelCopyWithImpl<$Res>
    implements _$GroupModelCopyWith<$Res> {
  __$GroupModelCopyWithImpl(this._self, this._then);

  final _GroupModel _self;
  final $Res Function(_GroupModel) _then;

/// Create a copy of GroupModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? joinCode = null,Object? memberUids = null,Object? status = null,Object? createdAt = null,Object? gameStartedAt = freezed,Object? gameEndedAt = freezed,}) {
  return _then(_GroupModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,joinCode: null == joinCode ? _self.joinCode : joinCode // ignore: cast_nullable_to_non_nullable
as String,memberUids: null == memberUids ? _self._memberUids : memberUids // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GroupStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,gameStartedAt: freezed == gameStartedAt ? _self.gameStartedAt : gameStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,gameEndedAt: freezed == gameEndedAt ? _self.gameEndedAt : gameEndedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

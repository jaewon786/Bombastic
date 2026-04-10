// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mission_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MissionModel {

 String get id; String get title; String get description; int get reward; MissionType get type; bool get isCompleted;
/// Create a copy of MissionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissionModelCopyWith<MissionModel> get copyWith => _$MissionModelCopyWithImpl<MissionModel>(this as MissionModel, _$identity);

  /// Serializes this MissionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.reward, reward) || other.reward == reward)&&(identical(other.type, type) || other.type == type)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,reward,type,isCompleted);

@override
String toString() {
  return 'MissionModel(id: $id, title: $title, description: $description, reward: $reward, type: $type, isCompleted: $isCompleted)';
}


}

/// @nodoc
abstract mixin class $MissionModelCopyWith<$Res>  {
  factory $MissionModelCopyWith(MissionModel value, $Res Function(MissionModel) _then) = _$MissionModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, int reward, MissionType type, bool isCompleted
});




}
/// @nodoc
class _$MissionModelCopyWithImpl<$Res>
    implements $MissionModelCopyWith<$Res> {
  _$MissionModelCopyWithImpl(this._self, this._then);

  final MissionModel _self;
  final $Res Function(MissionModel) _then;

/// Create a copy of MissionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? reward = null,Object? type = null,Object? isCompleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,reward: null == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MissionType,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MissionModel].
extension MissionModelPatterns on MissionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MissionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MissionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MissionModel value)  $default,){
final _that = this;
switch (_that) {
case _MissionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MissionModel value)?  $default,){
final _that = this;
switch (_that) {
case _MissionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  int reward,  MissionType type,  bool isCompleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MissionModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.reward,_that.type,_that.isCompleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  int reward,  MissionType type,  bool isCompleted)  $default,) {final _that = this;
switch (_that) {
case _MissionModel():
return $default(_that.id,_that.title,_that.description,_that.reward,_that.type,_that.isCompleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  int reward,  MissionType type,  bool isCompleted)?  $default,) {final _that = this;
switch (_that) {
case _MissionModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.reward,_that.type,_that.isCompleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MissionModel implements MissionModel {
  const _MissionModel({required this.id, required this.title, required this.description, required this.reward, required this.type, this.isCompleted = false});
  factory _MissionModel.fromJson(Map<String, dynamic> json) => _$MissionModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  int reward;
@override final  MissionType type;
@override@JsonKey() final  bool isCompleted;

/// Create a copy of MissionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MissionModelCopyWith<_MissionModel> get copyWith => __$MissionModelCopyWithImpl<_MissionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MissionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MissionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.reward, reward) || other.reward == reward)&&(identical(other.type, type) || other.type == type)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,reward,type,isCompleted);

@override
String toString() {
  return 'MissionModel(id: $id, title: $title, description: $description, reward: $reward, type: $type, isCompleted: $isCompleted)';
}


}

/// @nodoc
abstract mixin class _$MissionModelCopyWith<$Res> implements $MissionModelCopyWith<$Res> {
  factory _$MissionModelCopyWith(_MissionModel value, $Res Function(_MissionModel) _then) = __$MissionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, int reward, MissionType type, bool isCompleted
});




}
/// @nodoc
class __$MissionModelCopyWithImpl<$Res>
    implements _$MissionModelCopyWith<$Res> {
  __$MissionModelCopyWithImpl(this._self, this._then);

  final _MissionModel _self;
  final $Res Function(_MissionModel) _then;

/// Create a copy of MissionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? reward = null,Object? type = null,Object? isCompleted = null,}) {
  return _then(_MissionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,reward: null == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MissionType,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

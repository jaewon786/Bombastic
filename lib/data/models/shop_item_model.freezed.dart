// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shop_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShopItemModel {

 String get id; String get name; String get description; int get price; ItemType get type; bool get isAvailable;
/// Create a copy of ShopItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShopItemModelCopyWith<ShopItemModel> get copyWith => _$ShopItemModelCopyWithImpl<ShopItemModel>(this as ShopItemModel, _$identity);

  /// Serializes this ShopItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShopItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.type, type) || other.type == type)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,price,type,isAvailable);

@override
String toString() {
  return 'ShopItemModel(id: $id, name: $name, description: $description, price: $price, type: $type, isAvailable: $isAvailable)';
}


}

/// @nodoc
abstract mixin class $ShopItemModelCopyWith<$Res>  {
  factory $ShopItemModelCopyWith(ShopItemModel value, $Res Function(ShopItemModel) _then) = _$ShopItemModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, int price, ItemType type, bool isAvailable
});




}
/// @nodoc
class _$ShopItemModelCopyWithImpl<$Res>
    implements $ShopItemModelCopyWith<$Res> {
  _$ShopItemModelCopyWithImpl(this._self, this._then);

  final ShopItemModel _self;
  final $Res Function(ShopItemModel) _then;

/// Create a copy of ShopItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? price = null,Object? type = null,Object? isAvailable = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ItemType,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ShopItemModel].
extension ShopItemModelPatterns on ShopItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShopItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShopItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShopItemModel value)  $default,){
final _that = this;
switch (_that) {
case _ShopItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShopItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _ShopItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  int price,  ItemType type,  bool isAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShopItemModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.price,_that.type,_that.isAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  int price,  ItemType type,  bool isAvailable)  $default,) {final _that = this;
switch (_that) {
case _ShopItemModel():
return $default(_that.id,_that.name,_that.description,_that.price,_that.type,_that.isAvailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  int price,  ItemType type,  bool isAvailable)?  $default,) {final _that = this;
switch (_that) {
case _ShopItemModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.price,_that.type,_that.isAvailable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShopItemModel implements ShopItemModel {
  const _ShopItemModel({required this.id, required this.name, required this.description, required this.price, required this.type, this.isAvailable = true});
  factory _ShopItemModel.fromJson(Map<String, dynamic> json) => _$ShopItemModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  int price;
@override final  ItemType type;
@override@JsonKey() final  bool isAvailable;

/// Create a copy of ShopItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShopItemModelCopyWith<_ShopItemModel> get copyWith => __$ShopItemModelCopyWithImpl<_ShopItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShopItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShopItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.type, type) || other.type == type)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,price,type,isAvailable);

@override
String toString() {
  return 'ShopItemModel(id: $id, name: $name, description: $description, price: $price, type: $type, isAvailable: $isAvailable)';
}


}

/// @nodoc
abstract mixin class _$ShopItemModelCopyWith<$Res> implements $ShopItemModelCopyWith<$Res> {
  factory _$ShopItemModelCopyWith(_ShopItemModel value, $Res Function(_ShopItemModel) _then) = __$ShopItemModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, int price, ItemType type, bool isAvailable
});




}
/// @nodoc
class __$ShopItemModelCopyWithImpl<$Res>
    implements _$ShopItemModelCopyWith<$Res> {
  __$ShopItemModelCopyWithImpl(this._self, this._then);

  final _ShopItemModel _self;
  final $Res Function(_ShopItemModel) _then;

/// Create a copy of ShopItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? price = null,Object? type = null,Object? isAvailable = null,}) {
  return _then(_ShopItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ItemType,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

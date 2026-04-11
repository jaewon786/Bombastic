import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../firebase/firebase_providers.dart';
import '../models/shop_item_model.dart';

part 'shop_repository.g.dart';

@riverpod
ShopRepository shopRepository(Ref ref) {
  return ShopRepository(
    ref.watch(firestoreProvider),
    ref.watch(functionsProvider),
  );
}

class ShopRepository {
  ShopRepository(this._firestore, this._functions);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  /// 아이템 목록 조회
  Future<List<ShopItemModel>> fetchItems() async {
    final snap = await _firestore
        .collection(AppConstants.shopItemsCollection)
        .where('isAvailable', isEqualTo: true)
        .get();
    return snap.docs.map((d) => ShopItemModel.fromJson(d.data())).toList();
  }

  /// 아이템 목록 실시간 스트림
  Stream<List<ShopItemModel>> watchShopItems() {
    return _firestore
        .collection(AppConstants.shopItemsCollection)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ShopItemModel.fromJson(d.data())).toList());
  }

  /// 랜덤박스 구매 — Cloud Function 위임 (서버 측 랜덤·트랜잭션으로 조작 방지)
  /// 반환: 획득한 ShopItemModel
  Future<ShopItemModel> purchaseRandomBox({required String groupId}) async {
    final result = await _functions
        .httpsCallable('openLootBox')
        .call<Map<Object?, Object?>>({'groupId': groupId});

    final data = Map<String, dynamic>.from(result.data);
    final itemId = data['itemId'] as String;

    final itemSnap = await _firestore
        .collection(AppConstants.shopItemsCollection)
        .doc(itemId)
        .get();

    if (!itemSnap.exists) throw Exception('아이템 정보를 찾을 수 없습니다.');
    return ShopItemModel.fromJson(itemSnap.data()!);
  }
}

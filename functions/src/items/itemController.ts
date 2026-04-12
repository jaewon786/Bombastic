import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';


const db = admin.firestore();

/**
 * 아이템 사용 Callable Function.
 * data: { groupId: string; itemId: string; days?: number }
 */
export const useItem = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.');
  }

  const { groupId, itemId } = data as {
    groupId: string;
    itemId: string;
  };
  if (!groupId || !itemId) {
    throw new functions.https.HttpsError('invalid-argument', 'groupId와 itemId가 필요합니다.');
  }

  const uid = context.auth.uid;

  // ── 유저 소유 여부 확인 ──────────────────────────────────────
  const userRef = db.collection('users').doc(uid);
  const userSnap = await userRef.get();
  const groupOwned = (userSnap.data()?.groupOwnedItemIds as Record<string, string[]> | undefined) ?? {};
  const ownedItems = groupOwned[groupId] ?? [];
  if (!ownedItems.includes(itemId)) {
    throw new functions.https.HttpsError('permission-denied', '해당 아이템을 보유하지 않았습니다.');
  }
  const updatedOwnedItems = [...ownedItems];
  updatedOwnedItems.splice(updatedOwnedItems.indexOf(itemId), 1);

  // ── 아이템 정보 조회 ─────────────────────────────────────────
  const itemSnap = await db.collection('shopItems').doc(itemId).get();
  if (!itemSnap.exists) {
    throw new functions.https.HttpsError('not-found', '아이템을 찾을 수 없습니다.');
  }
  const item = itemSnap.data()!;

  // ── 그룹/게임 상태 확인 ──────────────────────────────────────
  const groupRef = db.collection('groups').doc(groupId);
  const groupSnap = await groupRef.get();
  if (!groupSnap.exists) {
    throw new functions.https.HttpsError('not-found', '그룹을 찾을 수 없습니다.');
  }
  const group = groupSnap.data()!;
  if (group.status !== 'playing') {
    throw new functions.https.HttpsError('failed-precondition', '게임 진행 중이 아닙니다.');
  }

  // ── 현재 활성 폭탄 조회 ──────────────────────────────────────
  const activeBombSnap = await db
    .collection('groups')
    .doc(groupId)
    .collection('bombs')
    .where('status', '==', 'active')
    .limit(1)
    .get();
  const activeBombDoc = activeBombSnap.docs[0];
  const activeBomb = activeBombDoc?.data();

  // bombHolder 전용 아이템: 폭탄 보유자만 사용 가능
  if (item.usageType === 'bombHolder' && activeBomb?.holderUid !== uid) {
    throw new functions.https.HttpsError(
      'permission-denied',
      '폭탄 보유자만 사용할 수 있는 아이템입니다.',
    );
  }

  const batch = db.batch();
  const members = group.memberUids as string[];
  let extraResult: Record<string, unknown> = {};

  // ── 아이템 효과 적용 ─────────────────────────────────────────
  switch (item.type as string) {
    case 'swapOrder': {
      // 내 위치 유지 + 나머지 순서 셔플
      const myIndex = members.indexOf(uid);
      const others = members.filter((_, i) => i !== myIndex);
      for (let i = others.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [others[i], others[j]] = [others[j], others[i]];
      }
      // 원래 인덱스에 정확히 삽입: before + me + after
      const newOrder = [
        ...others.slice(0, myIndex),
        uid,
        ...others.slice(myIndex),
      ];
      batch.update(groupRef, { memberUids: newOrder });
      break;
    }

    case 'reverseDirection': {
      // 전달 방향 반전 (배열 역순)
      batch.update(groupRef, { memberUids: [...members].reverse() });
      break;
    }

    case 'shrinkDuration': {
      // 모든 활성 폭탄 남은 시간 50% 단축
      if (!activeBombDoc) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          '활성 폭탄이 없어 사용할 수 없습니다.',
        );
      }
      const expiresAt = (activeBomb!.expiresAt as admin.firestore.Timestamp).toDate();
      const now = new Date();
      const remaining = expiresAt.getTime() - now.getTime();
      const newExpires = new Date(now.getTime() + remaining * 0.5);
      batch.update(activeBombDoc.ref, {
        expiresAt: admin.firestore.Timestamp.fromDate(newExpires),
      });
      break;
    }

    case 'guardianAngel': {
      // 수호천사는 패시브 아이템 — 폭발 시 자동 발동, 직접 사용 불가
      throw new functions.https.HttpsError(
        'failed-precondition',
        '수호천사는 자동 발동 아이템입니다. 직접 사용할 수 없습니다.',
      );
    }

    default:
      throw new functions.https.HttpsError('invalid-argument', `알 수 없는 아이템 타입: ${item.type}`);
  }

  // ── itemUsages 서브컬렉션에 사용 로그 기록 ───────────────────
  const usageRef = db
    .collection('groups')
    .doc(groupId)
    .collection('itemUsages')
    .doc();
  batch.set(usageRef, {
    uid,
    itemId,
    itemType: item.type,
    usedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // ── 인벤토리에서 아이템 제거 ─────────────────────────────────
  batch.update(userRef, {
    [`groupOwnedItemIds.${groupId}`]: updatedOwnedItems,
  });

  await batch.commit();
  functions.logger.info(`아이템 사용 완료: uid=${uid}, item=${itemId}, group=${groupId}`);

  return { success: true, ...extraResult };
});

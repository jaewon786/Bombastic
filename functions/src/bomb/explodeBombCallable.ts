import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

const db = admin.firestore();

const GUARDIAN_ANGEL_EXTRA_SECONDS = 10;

/**
 * 클라이언트에서 타이머 만료를 감지했을 때 호출하는 폭탄 폭발 Callable.
 * 서버 시간 기준으로 실제 만료 여부를 재검증한 뒤 폭발 처리한다.
 *
 * 수호천사 아이템 보유 시: 폭발을 1회 막고 10초 추가.
 *
 * data: { groupId: string, bombId: string }
 */
export const explodeBomb = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.');
  }

  const { groupId, bombId } = data as { groupId: string; bombId: string };
  if (!groupId || !bombId) {
    throw new functions.https.HttpsError('invalid-argument', 'groupId와 bombId가 필요합니다.');
  }

  const groupRef = db.collection('groups').doc(groupId);
  const bombRef = groupRef.collection('bombs').doc(bombId);

  const result = await db.runTransaction(async (tx) => {
    const bombSnap = await tx.get(bombRef);
    const bomb = bombSnap.data();

    if (!bomb || bomb.status !== 'active') {
      return { saved: false };
    }

    // 서버 시간 기준으로 실제 만료 여부 검증
    const now = admin.firestore.Timestamp.now();
    const expiresAt = bomb.expiresAt as admin.firestore.Timestamp;
    if (expiresAt.toMillis() > now.toMillis()) {
      return { saved: false };
    }

    const holderUid = bomb.holderUid as string;

    // ── 수호천사 아이템 확인 ──────────────────────────────────
    const userRef = db.collection('users').doc(holderUid);
    const userSnap = await tx.get(userRef);
    const groupOwned =
      (userSnap.data()?.groupOwnedItemIds as Record<string, string[]> | undefined) ?? {};
    const ownedItems = [...(groupOwned[groupId] ?? [])];
    const angelIndex = ownedItems.indexOf('guardianAngel');

    if (angelIndex !== -1) {
      // 수호천사 발동: 폭발 방지 + 10초 추가
      ownedItems.splice(angelIndex, 1);
      const newExpiresAt = admin.firestore.Timestamp.fromMillis(
        now.toMillis() + GUARDIAN_ANGEL_EXTRA_SECONDS * 1000,
      );

      tx.update(bombRef, {
        expiresAt: newExpiresAt,
      });

      tx.update(userRef, {
        [`groupOwnedItemIds.${groupId}`]: ownedItems,
      });

      // 아이템 사용 로그
      const usageRef = groupRef.collection('itemUsages').doc();
      tx.set(usageRef, {
        uid: holderUid,
        itemId: 'guardianAngel',
        itemType: 'guardianAngel',
        usedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { saved: true, holderUid };
    }

    // ── 수호천사 없음: 폭발 처리 ────────────────────────────
    tx.update(bombRef, {
      status: 'exploded',
      explodedUid: holderUid,
      explodedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const penaltyAmount = bomb.hasPenalty === true ? 2 : 1;
    tx.update(groupRef, {
      [`penaltyCount.${holderUid}`]: admin.firestore.FieldValue.increment(penaltyAmount),
    });

    return { saved: false };
  });

  return { success: true, ...result };
});

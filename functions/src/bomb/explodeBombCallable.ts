import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

const db = admin.firestore();

/**
 * 클라이언트에서 타이머 만료를 감지했을 때 호출하는 폭탄 폭발 Callable.
 * 서버 시간 기준으로 실제 만료 여부를 재검증한 뒤 폭발 처리한다.
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

  await db.runTransaction(async (tx) => {
    const bombSnap = await tx.get(bombRef);
    const bomb = bombSnap.data();

    if (!bomb || bomb.status !== 'active') {
      // 이미 처리됨 — 중복 호출은 무시
      return;
    }

    // 서버 시간 기준으로 실제 만료 여부 검증
    const now = admin.firestore.Timestamp.now();
    const expiresAt = bomb.expiresAt as admin.firestore.Timestamp;
    if (expiresAt.toMillis() > now.toMillis()) {
      // 아직 만료 전 — 클라이언트 클럭 오차로 인한 조기 호출
      return;
    }

    const holderUid = bomb.holderUid as string;

    tx.update(bombRef, {
      status: 'exploded',
      explodedUid: holderUid,
      explodedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 패널티 카운트
    const penaltyAmount = bomb.hasPenalty === true ? 2 : 1;
    tx.update(groupRef, {
      [`penaltyCount.${holderUid}`]: admin.firestore.FieldValue.increment(penaltyAmount),
    });
  });

  return { success: true };
});

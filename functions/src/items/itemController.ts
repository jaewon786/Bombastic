import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

import { bombDefaultDurationMs } from '../core/gameConfig';

const db = admin.firestore();

/**
 * 아이템 사용 Callable Function.
 * data: { groupId: string; itemId: string; days?: number }
 */
export const useItem = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.');
  }

  const { groupId, itemId, days } = data as {
    groupId: string;
    itemId: string;
    days?: number;
  };
  if (!groupId || !itemId) {
    throw new functions.https.HttpsError('invalid-argument', 'groupId와 itemId가 필요합니다.');
  }

  const uid = context.auth.uid;

  // ── 유저 소유 여부 확인 ──────────────────────────────────────
  const userRef = db.collection('users').doc(uid);
  const userSnap = await userRef.get();
  const ownedItems = (userSnap.data()?.ownedItemIds as string[]) ?? [];
  if (!ownedItems.includes(itemId)) {
    throw new functions.https.HttpsError('permission-denied', '해당 아이템을 보유하지 않았습니다.');
  }

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
      others.splice(myIndex, 0, uid);
      batch.update(groupRef, { memberUids: others });
      break;
    }

    case 'reverseDirection': {
      // 전달 방향 반전 (배열 역순)
      batch.update(groupRef, { memberUids: [...members].reverse() });
      break;
    }

    case 'shrinkDuration': {
      // 모든 활성 폭탄 남은 시간 50% 단축
      if (!activeBombDoc) break;
      const expiresAt = (activeBomb!.expiresAt as admin.firestore.Timestamp).toDate();
      const now = new Date();
      const remaining = expiresAt.getTime() - now.getTime();
      const newExpires = new Date(now.getTime() + remaining * 0.5);
      batch.update(activeBombDoc.ref, {
        expiresAt: admin.firestore.Timestamp.fromDate(newExpires),
      });
      break;
    }

    case 'enhancePenalty': {
      // 현재 폭탄에 패널티 강화 플래그 추가
      if (!activeBombDoc) {
        throw new functions.https.HttpsError('not-found', '활성 폭탄이 없습니다.');
      }
      batch.update(activeBombDoc.ref, { hasPenalty: true });
      break;
    }

    case 'addBomb': {
      // 랜덤 멤버(현재 보유자 제외)에게 새 폭탄 추가
      const holderUid = activeBomb?.holderUid as string | undefined;
      const eligible = members.filter((m) => m !== holderUid);
      if (eligible.length === 0) {
        throw new functions.https.HttpsError('failed-precondition', '새 폭탄을 전달할 멤버가 없습니다.');
      }
      const target = eligible[Math.floor(Math.random() * eligible.length)];
      extraResult = { targetUid: target };
      const now2 = admin.firestore.Timestamp.now();
      const newBombRef = db
        .collection('groups')
        .doc(groupId)
        .collection('bombs')
        .doc();
      batch.set(newBombRef, {
        id: newBombRef.id,
        groupId,
        holderUid: target,
        receivedAt: now2,
        expiresAt: admin.firestore.Timestamp.fromDate(
          new Date(now2.toMillis() + bombDefaultDurationMs),
        ),
        status: 'active',
        round: 1,
        explodedUid: null,
        hasPenalty: false,
      });
      break;
    }

    case 'adjustGameDays': {
      // 게임 전체 만료 시간 ±N일 조정 (group.gameExpiresAt 기준)
      const adjustDays = typeof days === 'number' ? days : 1;
      const currentExpires = group.gameExpiresAt
        ? (group.gameExpiresAt as admin.firestore.Timestamp).toDate()
        : new Date();
      const newGameExpires = new Date(
        currentExpires.getTime() + adjustDays * 24 * 60 * 60 * 1000,
      );
      // 최소 1분 후 보장
      const minExpires = new Date(Date.now() + 60 * 1000);
      batch.update(groupRef, {
        gameExpiresAt: admin.firestore.Timestamp.fromDate(
          newGameExpires > minExpires ? newGameExpires : minExpires,
        ),
      });
      break;
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
    ownedItemIds: admin.firestore.FieldValue.arrayRemove(itemId),
  });

  await batch.commit();
  functions.logger.info(`아이템 사용 완료: uid=${uid}, item=${itemId}, group=${groupId}`);

  return { success: true, ...extraResult };
});

import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

const db = admin.firestore();

/**
 * Admin CLI 명령어 실행 Callable Function.
 * Admin SDK를 사용하므로 Firestore Rules를 우회한다.
 *
 * data: { command: string, groupId: string }
 */
export const adminCommand = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.');
  }

  const { command, groupId } = data as { command: string; groupId: string };
  if (!command || !groupId) {
    throw new functions.https.HttpsError('invalid-argument', 'command와 groupId가 필요합니다.');
  }

  const uid = context.auth.uid;
  const parts = command.trim().split(' ');
  const cmd = parts[0].toLowerCase();

  switch (cmd) {
    case '/money': {
      const amount = parts.length > 1 ? parseInt(parts[1], 10) || 10000 : 10000;
      await db.runTransaction(async (tx) => {
        const userRef = db.collection('users').doc(uid);
        const snap = await tx.get(userRef);
        const currencies = (snap.data()?.groupCurrencies as Record<string, number>) ?? {};
        const current = currencies[groupId] ?? 0;
        tx.update(userRef, { [`groupCurrencies.${groupId}`]: current + amount });
      });
      return { success: true, message: `재화 ${amount} 추가 완료` };
    }

    case '/items': {
      const itemsSnap = await db.collection('shopItems').get();
      const ids = itemsSnap.docs.map((d) => d.id);
      const userRef = db.collection('users').doc(uid);
      const userSnap = await userRef.get();
      const ownedGroups =
        (userSnap.data()?.groupOwnedItemIds as Record<string, string[]> | undefined) ?? {};
      const currentOwnedItems = [...(ownedGroups[groupId] ?? [])];

      await userRef.update({
        [`groupOwnedItemIds.${groupId}`]: [...currentOwnedItems, ...ids],
      });
      return { success: true, message: `아이템 ${ids.length}개 지급 완료` };
    }

    case '/explode': {
      const bombSnap = await db
        .collection('groups')
        .doc(groupId)
        .collection('bombs')
        .where('status', '==', 'active')
        .limit(1)
        .get();

      if (bombSnap.empty) {
        throw new functions.https.HttpsError('not-found', '진행 중인 게임(폭탄)이 없습니다.');
      }

      const bombDoc = bombSnap.docs[0];
      if (bombDoc.data().holderUid !== uid) {
        throw new functions.https.HttpsError('permission-denied', '나에게 폭탄이 있을 때만 즉시 터뜨릴 수 있습니다!');
      }

      await bombDoc.ref.update({
        expiresAt: admin.firestore.Timestamp.now(),
      });
      return { success: true, message: '폭탄 즉시 만료 처리 완료' };
    }

    case '/mission': {
      await db.collection('users').doc(uid).update({
        [`groupLastCheckInDate.${groupId}`]: admin.firestore.FieldValue.delete(),
        [`groupCompletedMissionIds.${groupId}`]: admin.firestore.FieldValue.delete(),
      });
      return { success: true, message: '출석 및 미션 기록 초기화 완료 (이 그룹)' };
    }

    case '/steal': {
      const bombSnap2 = await db
        .collection('groups')
        .doc(groupId)
        .collection('bombs')
        .where('status', '==', 'active')
        .limit(1)
        .get();

      if (bombSnap2.empty) {
        throw new functions.https.HttpsError('not-found', '진행 중인 게임(폭탄)이 없습니다.');
      }

      await bombSnap2.docs[0].ref.update({
        holderUid: uid,
        receivedAt: admin.firestore.Timestamp.now(),
        expiresAt: admin.firestore.Timestamp.fromDate(
          new Date(Date.now() + 15 * 1000),
        ),
      });
      return { success: true, message: '폭탄 강탈 완료 (15초)' };
    }

    case '/endgame': {
      await db.collection('groups').doc(groupId).update({
        status: 'finished',
        gameEndedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      const bombSnap3 = await db
        .collection('groups')
        .doc(groupId)
        .collection('bombs')
        .where('status', '==', 'active')
        .limit(1)
        .get();

      if (!bombSnap3.empty) {
        await bombSnap3.docs[0].ref.update({
          status: 'exploded',
        });
      }
      return { success: true, message: '게임 종료 처리 완료' };
    }

    default:
      throw new functions.https.HttpsError('invalid-argument', `알 수 없는 명령어: ${cmd}`);
  }
});

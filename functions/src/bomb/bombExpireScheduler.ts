import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

const db = admin.firestore();

function buildResultSummary(
  group: FirebaseFirestore.DocumentData | undefined,
  reason: 'expired' | 'exploded',
) {
  const memberUids = Array.isArray(group?.memberUids)
    ? (group?.memberUids as unknown[]).filter((v): v is string => typeof v === 'string')
    : [];
  const penaltyCount =
    group?.penaltyCount && typeof group.penaltyCount === 'object'
      ? group.penaltyCount
      : {};

  return {
    finalizedAt: admin.firestore.FieldValue.serverTimestamp(),
    memberUids,
    penaltyCount,
    reason,
  };
}

/**
 * 1분마다 실행되는 폭탄 만료 감지 스케줄러.
 * expiresAt이 현재 시각보다 이전이고 status가 'active'인 폭탄을 찾아 폭발 처리.
 */
export const checkBombExpiry = functions
  .runWith({ timeoutSeconds: 60, memory: '256MB' })
  .pubsub.schedule('every 1 minutes')
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();

    const snapshot = await db
      .collectionGroup('bombs')
      .where('status', '==', 'active')
      .where('expiresAt', '<=', now)
      .get();

    if (snapshot.empty) {
      functions.logger.info('만료된 폭탄 없음');
      return;
    }

    const batch = db.batch();

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const holderUid = data.holderUid as string;

      functions.logger.info(`폭탄 폭발 처리: ${doc.id}, 보유자: ${holderUid}`);

      // 폭탄 상태를 exploded로 변경
      batch.update(doc.ref, {
        status: 'exploded',
        explodedUid: holderUid,
        explodedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 그룹 문서에 패널티 카운트 증가
      const groupId = data.groupId as string;
      const groupRef = db.collection('groups').doc(groupId);
      batch.update(groupRef, {
        [`penaltyCount.${holderUid}`]: admin.firestore.FieldValue.increment(1),
      });
    }

    await batch.commit();
    functions.logger.info(`${snapshot.size}개 폭탄 폭발 처리 완료`);
  });

/**
 * 1분마다 실행되는 게임 7일 만료 감지 스케줄러.
 * gameExpiresAt이 현재 시각보다 이전이고 status가 'playing'인 그룹을 찾아 종료 처리.
 */
export const checkGameExpiry = functions
  .runWith({ timeoutSeconds: 60, memory: '256MB' })
  .pubsub.schedule('every 1 minutes')
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();

    const snapshot = await db
      .collection('groups')
      .where('status', '==', 'playing')
      .where('gameExpiresAt', '<=', now)
      .get();

    if (snapshot.empty) {
      functions.logger.info('만료된 게임 없음');
      return;
    }

    let processedCount = 0;

    for (const doc of snapshot.docs) {
      try {
        const group = doc.data();
        functions.logger.info(`게임 7일 만료 처리: ${doc.id}`);

        await doc.ref.update({
          status: 'finished',
          gameEndedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        await doc.ref
          .collection('results')
          .doc('summary')
          .set(buildResultSummary(group, 'expired'));

        processedCount++;
      } catch (err) {
        functions.logger.error(`게임 만료 처리 실패: ${doc.id}`, err);
      }
    }

    functions.logger.info(`${processedCount}/${snapshot.size}개 게임 만료 처리 완료`);
  });

/**
 * 폭탄 폭발 시 Firestore 트리거 (onUpdate).
 * status가 'exploded'로 변경된 시점에 다음 라운드 폭탄 생성.
 */
export const onBombExploded = functions.firestore
  .document('groups/{groupId}/bombs/{bombId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status === after.status) return; // 변경 없음
    if (after.status !== 'exploded') return;    // 폭발이 아닌 경우 skip

    const { groupId } = context.params;
    functions.logger.info(`그룹 ${groupId} 폭탄 폭발 → 게임 종료 처리`);

    // 폭발 즉시 게임 종료
    const groupRef = db.collection('groups').doc(groupId);
    const groupSnap = await groupRef.get();
    const group = groupSnap.data();

    if (group?.status === 'finished') {
      functions.logger.info(`그룹 ${groupId} 이미 종료됨, skip`);
      return;
    }

    await groupRef.update({
      status: 'finished',
      gameEndedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await groupRef
      .collection('results')
      .doc('summary')
      .set(buildResultSummary(group, 'exploded'));

    functions.logger.info(`그룹 ${groupId} 게임 종료`);
  });

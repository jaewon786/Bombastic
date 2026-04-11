import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

import { bombDefaultDurationMs } from '../core/gameConfig';

const db = admin.firestore();

/**
 * 그룹 멤버가 4명이 되면 자동으로 게임을 시작하고 첫 폭탄을 생성.
 */
export const onGroupMemberJoined = functions.firestore
  .document('groups/{groupId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    const beforeCount: number = (before.memberUids as string[]).length;
    const afterCount: number = (after.memberUids as string[]).length;

    // 4명이 됐을 때만 실행
    if (beforeCount === afterCount) return;
    if (afterCount !== after.maxMembers) return;
    if (after.status !== 'waiting') return;

    const { groupId } = context.params;
    functions.logger.info(`그룹 ${groupId} 4명 완성 → 게임 시작`);

    const now = admin.firestore.Timestamp.now();
    const expiresAt = new Date(now.toMillis() + bombDefaultDurationMs);
    const gameExpiresAt = new Date(now.toMillis() + 7 * 24 * 60 * 60 * 1000);

    // 첫 폭탄 생성 (첫 번째 멤버가 보유)
    const firstHolder = (after.memberUids as string[])[0];
    const bombRef = db.collection('groups').doc(groupId).collection('bombs').doc();

    const batch = db.batch();

    batch.set(bombRef, {
      id: bombRef.id,
      groupId,
      holderUid: firstHolder,
      receivedAt: now,
      expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
      status: 'active',
      round: 1,
      explodedUid: null,
    });

    batch.update(change.after.ref, {
      status: 'playing',
      gameStartedAt: now,
      gameExpiresAt: admin.firestore.Timestamp.fromDate(gameExpiresAt),
    });

    await batch.commit();
    functions.logger.info(`폭탄 생성 완료: ${bombRef.id}, 첫 보유자: ${firstHolder}`);
  });

/**
 * 그룹 생성 시 초기 데이터 세팅 (Callable Function).
 */
export const createGroup = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.');
  }

  const { joinCode } = data as { joinCode: string };
  if (!joinCode || joinCode.length !== 6) {
    throw new functions.https.HttpsError('invalid-argument', '올바른 참여코드가 필요합니다.');
  }

  const uid = context.auth.uid;

  // 중복 코드 체크 (클라이언트 생성 방식 유지; 충돌 시 클라이언트가 재시도)
  const existing = await db
    .collection('groups')
    .where('joinCode', '==', joinCode.toUpperCase())
    .where('status', '==', 'waiting')
    .limit(1)
    .get();
  if (!existing.empty) {
    throw new functions.https.HttpsError('already-exists', '이미 사용 중인 참여코드입니다. 다시 시도해 주세요.');
  }

  const groupRef = db.collection('groups').doc();

  await groupRef.set({
    id: groupRef.id,
    joinCode: joinCode.toUpperCase(),
    memberUids: [uid],
    status: 'waiting',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    penaltyCount: {},
  });

  return { groupId: groupRef.id };
});

/**
 * 방장이 게임을 시작하는 Callable Function.
 */
export const startGame = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.');
  }

  const { groupId } = data as { groupId: string };
  if (!groupId) {
    throw new functions.https.HttpsError('invalid-argument', 'groupId가 필요합니다.');
  }

  const groupRef = db.collection('groups').doc(groupId);
  const groupSnap = await groupRef.get();
  if (!groupSnap.exists) {
    throw new functions.https.HttpsError('not-found', '그룹을 찾을 수 없습니다.');
  }

  const group = groupSnap.data()!;

  if (group.memberUids[0] !== context.auth.uid) {
    throw new functions.https.HttpsError('permission-denied', '방장만 게임을 시작할 수 있습니다.');
  }

  if (group.status !== 'waiting') {
    throw new functions.https.HttpsError('failed-precondition', '이미 시작된 게임입니다.');
  }
  if (group.memberUids.length < 2) {
    throw new functions.https.HttpsError('failed-precondition', '최소 2명이 필요합니다.');
  }

  const now = admin.firestore.Timestamp.now();
  const expiresAt = new Date(now.toMillis() + bombDefaultDurationMs);
  const gameExpiresAt = new Date(now.toMillis() + 7 * 24 * 60 * 60 * 1000);
  const firstHolder = group.memberUids[0];
  const bombRef = db.collection('groups').doc(groupId).collection('bombs').doc();

  const batch = db.batch();
  batch.set(bombRef, {
    id: bombRef.id,
    groupId,
    holderUid: firstHolder,
    receivedAt: now,
    expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
    status: 'active',
    round: 1,
    explodedUid: null,
  });
  batch.update(groupRef, {
    status: 'playing',
    gameStartedAt: now,
    gameExpiresAt: admin.firestore.Timestamp.fromDate(gameExpiresAt),
  });

  await batch.commit();
  return { success: true, bombId: bombRef.id };
});

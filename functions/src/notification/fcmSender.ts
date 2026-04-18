import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

const db = admin.firestore();
const messaging = admin.messaging();

interface SendPushOptions {
  uid: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

/**
 * 특정 유저에게 FCM 푸시 알림 발송 (uid -> FCM 토큰 조회 후 전송).
 * 토큰이 만료/삭제된 경우 Firestore에서 토큰을 자동 정리한다.
 */
async function sendPushToUser({ uid, title, body, data }: SendPushOptions): Promise<void> {
  const userSnap = await db.collection('users').doc(uid).get();
  const fcmToken = userSnap.data()?.fcmToken as string | undefined;

  if (!fcmToken) {
    functions.logger.warn(`FCM 토큰 없음: ${uid}`);
    return;
  }

  try {
    await messaging.send({
      token: fcmToken,
      notification: { title, body },
      data,
      android: {
        priority: 'high',
        notification: { channelId: 'bombastic_channel' },
      },
      apns: {
        payload: { aps: { sound: 'default', badge: 1 } },
      },
    });
    functions.logger.info(`푸시 발송 완료: ${uid} -> "${title}"`);
  } catch (err: unknown) {
    const error = err as { code?: string };
    // 토큰이 더 이상 유효하지 않으면 Firestore에서 정리
    if (
      error.code === 'messaging/registration-token-not-registered' ||
      error.code === 'messaging/invalid-registration-token'
    ) {
      functions.logger.warn(`만료된 FCM 토큰 정리: ${uid}`);
      await db.collection('users').doc(uid).update({
        fcmToken: admin.firestore.FieldValue.delete(),
      });
    } else {
      functions.logger.error(`푸시 발송 실패: ${uid}`, err);
    }
  }
}

/**
 * 여러 유저에게 동시에 푸시 발송.
 * 특정 유저를 제외할 수 있다 (예: 본인에게는 알림 불필요).
 */
async function sendPushToUsers(
  uids: string[],
  options: Omit<SendPushOptions, 'uid'>,
  excludeUid?: string,
): Promise<void> {
  const targets = excludeUid ? uids.filter((uid) => uid !== excludeUid) : uids;
  await Promise.all(targets.map((uid) => sendPushToUser({ uid, ...options })));
}

/**
 * 남은 시간을 사람이 읽기 좋은 문자열로 변환.
 */
function formatRemaining(expiresAtMs: number): string {
  const remainMs = expiresAtMs - Date.now();
  if (remainMs <= 0) return '곧';

  const totalMinutes = Math.floor(remainMs / 60000);
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;

  if (hours > 0) return `${hours}시간 ${minutes}분`;
  return `${minutes}분`;
}

// ── 폭탄 전달 알림 ──────────────────────────────────────────────

/**
 * 폭탄을 받은 사람에게 알림 발송.
 * Firestore bomb 문서의 holderUid 변경 시 트리거.
 */
export const notifyBombReceived = functions.firestore
  .document('groups/{groupId}/bombs/{bombId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // holderUid가 변경되지 않은 경우 (타이머 변경 등) skip
    if (before.holderUid === after.holderUid) return;

    // 폭발 상태 변경은 별도 알림에서 처리
    if (after.status === 'exploded') return;

    const { groupId } = context.params;
    const newHolder = after.holderUid as string;
    const fromUid = before.holderUid as string;
    const expiresAt = (after.expiresAt as admin.firestore.Timestamp).toDate();

    // 보낸 사람 닉네임 조회
    const groupSnap = await db.collection('groups').doc(groupId).get();
    const nicknames = (groupSnap.data()?.memberNicknames as Record<string, string>) ?? {};
    const fromName = nicknames[fromUid] ?? '누군가';

    await sendPushToUser({
      uid: newHolder,
      title: '💣 폭탄이 도착했습니다!',
      body: `${fromName}님이 폭탄을 전달했습니다! ${formatRemaining(expiresAt.getTime())} 안에 전달하세요!`,
      data: { type: 'BOMB_RECEIVED', groupId },
    });
  });

// ── 폭탄 폭발 알림 ──────────────────────────────────────────────

/**
 * 폭탄 폭발 시 그룹 전원에게 알림 발송.
 * bombExpireScheduler.ts의 onBombExploded와 같은 document path를 감시하므로
 * 별도 함수로 분리하여 알림 전용으로 동작.
 */
export const notifyBombExploded = functions.firestore
  .document('groups/{groupId}/bombs/{bombId}')
  .onWrite(async (change, context) => {
    // onUpdate와 달리 onWrite를 사용하여 중복 트리거 방지
    const before = change.before.data();
    const after = change.after.data();

    if (!after) return; // 삭제된 경우
    if (before?.status === after.status) return; // 상태 변경 없음
    if (after.status !== 'exploded') return;

    const { groupId } = context.params;
    const explodedUid = after.explodedUid as string;

    // 그룹 정보에서 닉네임과 멤버 목록 조회
    const groupSnap = await db.collection('groups').doc(groupId).get();
    const group = groupSnap.data();
    const memberUids = (group?.memberUids as string[]) ?? [];
    const nicknames = (group?.memberNicknames as Record<string, string>) ?? {};
    const explodedName = nicknames[explodedUid] ?? '누군가';
    const groupName = (group?.name as string) ?? '그룹';

    // 폭발 당한 사람에게는 별도 메시지
    await sendPushToUser({
      uid: explodedUid,
      title: '💥 폭탄이 폭발했습니다!',
      body: `${groupName}에서 폭탄이 폭발했습니다... 게임이 종료되었습니다.`,
      data: { type: 'BOMB_EXPLODED', groupId },
    });

    // 나머지 멤버에게 알림
    await sendPushToUsers(
      memberUids,
      {
        title: '💥 폭탄이 폭발했습니다!',
        body: `${explodedName}님에게 폭탄이 폭발했습니다! 게임이 종료되었습니다.`,
        data: { type: 'BOMB_EXPLODED', groupId },
      },
      explodedUid,
    );
  });

// ── 폭탄 만료 임박 경고 ─────────────────────────────────────────

/**
 * 폭탄 만료 1시간 전 경고 알림.
 * 5분마다 실행되며, 만료 임박 폭탄 보유자에게 반복적으로 경고한다.
 */
export const notifyBombWarning = functions.pubsub
  .schedule('every 5 minutes')
  .onRun(async () => {
    const now = Date.now();
    const warningThreshold = new Date(now + 60 * 60 * 1000); // 1시간 후

    const snapshot = await db
      .collectionGroup('bombs')
      .where('status', '==', 'active')
      .where('expiresAt', '<=', admin.firestore.Timestamp.fromDate(warningThreshold))
      .where('expiresAt', '>', admin.firestore.Timestamp.fromMillis(now))
      .get();

    let sentCount = 0;

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const holderUid = data.holderUid as string;
      const expiresAt = (data.expiresAt as admin.firestore.Timestamp).toDate();
      const remaining = formatRemaining(expiresAt.getTime());

      await sendPushToUser({
        uid: holderUid,
        title: '⚠️ 폭탄 만료 임박!',
        body: `${remaining} 안에 전달하지 않으면 폭발합니다!`,
        data: { type: 'BOMB_WARNING' },
      });

      sentCount++;
    }

    if (sentCount > 0) {
      functions.logger.info(`폭탄 경고 알림 ${sentCount}건 발송`);
    }
  });

// ── 게임 시작 알림 ──────────────────────────────────────────────

/**
 * 게임이 시작되면 전체 멤버에게 알림 발송.
 * 그룹 status가 waiting -> playing으로 변경될 때 트리거.
 */
export const notifyGameStarted = functions.firestore
  .document('groups/{groupId}')
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status === after.status) return;
    if (before.status !== 'waiting' || after.status !== 'playing') return;

    const memberUids = (after.memberUids as string[]) ?? [];
    const groupName = (after.name as string) ?? '그룹';
    const groupId = change.after.id;

    // 방장(첫 번째 멤버, 첫 폭탄 보유자)에게는 별도 메시지
    const hostUid = memberUids[0];
    await sendPushToUser({
      uid: hostUid,
      title: '🎮 게임이 시작되었습니다!',
      body: `${groupName} 게임 시작! 첫 번째 폭탄이 당신에게 있습니다!`,
      data: { type: 'GAME_STARTED', groupId },
    });

    // 나머지 멤버에게 알림
    await sendPushToUsers(
      memberUids,
      {
        title: '🎮 게임이 시작되었습니다!',
        body: `${groupName} 게임이 시작되었습니다! 앱을 확인하세요!`,
        data: { type: 'GAME_STARTED', groupId },
      },
      hostUid,
    );
  });

// ── 게임 종료 알림 (7일 만료) ────────────────────────────────────

/**
 * 게임이 종료되면 전체 멤버에게 알림 발송.
 * 그룹 status가 playing -> finished로 변경될 때 트리거.
 * 폭발 종료는 notifyBombExploded에서 처리하므로, 7일 만료 종료만 담당.
 */
export const notifyGameFinished = functions.firestore
  .document('groups/{groupId}')
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status === after.status) return;
    if (before.status !== 'playing' || after.status !== 'finished') return;

    const memberUids = (after.memberUids as string[]) ?? [];
    const groupName = (after.name as string) ?? '그룹';
    const groupId = change.after.id;

    // 폭발로 인한 종료인지 확인 (폭발 종료는 notifyBombExploded에서 처리)
    // 폭발 종료와 7일 만료 종료를 구분하기 위해 bombs 컬렉션 확인
    const explodedBombs = await db
      .collection('groups')
      .doc(groupId)
      .collection('bombs')
      .where('status', '==', 'exploded')
      .limit(1)
      .get();

    // 폭발된 폭탄이 있으면 → notifyBombExploded에서 이미 알림 발송
    if (!explodedBombs.empty) return;

    // 7일 만료 종료 → 전원 알림
    await sendPushToUsers(memberUids, {
      title: '🏆 게임이 종료되었습니다!',
      body: `${groupName} 게임이 기간 만료로 종료되었습니다! 결과를 확인하세요!`,
      data: { type: 'GAME_FINISHED', groupId },
    });
  });

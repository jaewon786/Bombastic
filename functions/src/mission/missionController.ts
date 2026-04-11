import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

const db = admin.firestore();

const DAILY_CHECK_IN_REWARD = 50;

function getSeoulTodayKey() {
  const now = new Date();
  const seoulDate = new Date(
    now.toLocaleString('en-US', { timeZone: 'Asia/Seoul' }),
  );
  return `${seoulDate.getFullYear()}-${String(seoulDate.getMonth() + 1).padStart(2, '0')}-${String(seoulDate.getDate()).padStart(2, '0')}`;
}

/**
 * 서버 기준 오늘 날짜 조회 Callable Function.
 */
export const getTodayKey = functions.https.onCall(async (_data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.');
  }

  return { todayKey: getSeoulTodayKey() };
});

/**
 * 출석 체크 Callable Function.
 * data: { groupId: string }
 */
export const checkIn = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.');
  }

  const { groupId } = data as { groupId: string };
  if (!groupId) {
    throw new functions.https.HttpsError('invalid-argument', 'groupId가 필요합니다.');
  }

  const uid = context.auth.uid;
  const userRef = db.collection('users').doc(uid);

  // Asia/Seoul 기준 오늘 날짜 (YYYY-MM-DD)
  const todayKey = getSeoulTodayKey();

  return db.runTransaction(async (tx) => {
    const userSnap = await tx.get(userRef);
    const userData = userSnap.data();
    const lastCheckIn = userData?.lastCheckInDate as string | undefined;

    if (lastCheckIn === todayKey) {
      throw new functions.https.HttpsError('already-exists', '오늘은 이미 출석했습니다.');
    }

    tx.update(userRef, {
      lastCheckInDate: todayKey,
      [`groupCurrencies.${groupId}`]: admin.firestore.FieldValue.increment(DAILY_CHECK_IN_REWARD),
    });

    return { success: true, reward: DAILY_CHECK_IN_REWARD };
  });
});

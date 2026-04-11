import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

const db = admin.firestore();
const RANDOM_BOX_PRICE = 100;

/**
 * 랜덤박스 구매 Callable Function.
 * - 서버 측에서 가중치 랜덤 선택 (조작 방지)
 * - Firestore 트랜잭션으로 재화 차감 + 아이템 지급 원자 처리
 * data: { groupId: string }
 */
export const openLootBox = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.');
  }

  const { groupId } = data as { groupId: string };
  if (!groupId) {
    throw new functions.https.HttpsError('invalid-argument', 'groupId가 필요합니다.');
  }

  const uid = context.auth.uid;

  // ── 1. 뽑기 풀 조회 ──────────────────────────────────────────
  const itemsSnap = await db
    .collection('shopItems')
    .where('isAvailable', '==', true)
    .get();

  type PoolItem = {
    id: string;
    name: string;
    type: string;
    description: string;
    usageType: string;
    probability: number;
  };

  const pool = itemsSnap.docs
    .map((d) => ({ id: d.id, ...d.data() } as PoolItem))
    .filter((item) => item.probability > 0);

  if (pool.length === 0) {
    throw new functions.https.HttpsError('not-found', '뽑기 가능한 아이템이 없습니다.');
  }

  // ── 2. 가중치 기반 서버 랜덤 선택 ────────────────────────────
  const totalWeight = pool.reduce((acc, i) => acc + i.probability, 0);
  const roll = Math.floor(Math.random() * totalWeight);
  let cumulative = 0;
  let obtained = pool[pool.length - 1];
  for (const item of pool) {
    cumulative += item.probability;
    if (roll < cumulative) {
      obtained = item;
      break;
    }
  }

  // ── 3. 트랜잭션: 재화 차감 + 아이템 지급 ────────────────────
  const userRef = db.collection('users').doc(uid);
  let remainingCurrency = 0;

  await db.runTransaction(async (tx) => {
    const userSnap = await tx.get(userRef);
    if (!userSnap.exists) {
      throw new functions.https.HttpsError('not-found', '유저를 찾을 수 없습니다.');
    }

    const currencies =
      (userSnap.data()?.groupCurrencies as Record<string, number> | undefined) ?? {};
    const currentCurrency = currencies[groupId] ?? 0;

    if (currentCurrency < RANDOM_BOX_PRICE) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        `재화가 부족합니다. 현재: ${currentCurrency}, 필요: ${RANDOM_BOX_PRICE}`,
      );
    }

    remainingCurrency = currentCurrency - RANDOM_BOX_PRICE;

    tx.update(userRef, {
      [`groupCurrencies.${groupId}`]: remainingCurrency,
      [`groupOwnedItemIds.${groupId}`]: admin.firestore.FieldValue.arrayUnion(obtained.id),
    });
  });

  functions.logger.info(`랜덤박스 구매: uid=${uid}, group=${groupId}, item=${obtained.id}`);

  return {
    success: true,
    itemId: obtained.id,
    itemName: obtained.name,
    itemType: obtained.type,
    remainingCurrency,
  };
});

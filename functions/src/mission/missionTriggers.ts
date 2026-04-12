import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

const db = admin.firestore();

const MISSION_REWARD = 30;

/**
 * 미션 정의.
 * - mission_1: 첫 전달 완료 (pass 로그 1건 이상)
 * - mission_3: 아이템 첫 구매 (groupOwnedItemIds에 아이템 1개 이상)
 * - mission_4: 폭탄 5회 전달 (pass 로그 5건 이상)
 * - mission_5: 폭탄 10회 전달 (pass 로그 10건 이상)
 * - mission_6: 뽑기 3회 (lootBoxCount >= 3)
 * - mission_7: 빠른 전달 (10분 이내 전달 1회 이상)
 */
interface MissionCheck {
  id: string;
  check: (ctx: MissionContext) => boolean;
}

interface MissionContext {
  passCount: number;
  hasAnyItem: boolean;
  lootBoxCount: number;
  hasQuickPass: boolean;
}

const MISSIONS: MissionCheck[] = [
  {
    id: 'mission_1',
    check: (ctx) => ctx.passCount >= 1,
  },
  {
    id: 'mission_3',
    check: (ctx) => ctx.hasAnyItem,
  },
  {
    id: 'mission_4',
    check: (ctx) => ctx.passCount >= 5,
  },
  {
    id: 'mission_5',
    check: (ctx) => ctx.passCount >= 10,
  },
  {
    id: 'mission_6',
    check: (ctx) => ctx.lootBoxCount >= 3,
  },
  {
    id: 'mission_7',
    check: (ctx) => ctx.hasQuickPass,
  },
];

/**
 * 미션 달성 검사 + 보상 지급 공통 로직.
 */
async function evaluateMissions(uid: string, groupId: string): Promise<string[]> {
  const userRef = db.collection('users').doc(uid);
  const groupRef = db.collection('groups').doc(groupId);

  // pass 횟수 집계
  const passSnap = await groupRef
    .collection('passes')
    .where('fromUid', '==', uid)
    .get();
  const passCount = passSnap.size;

  // 10분 이내 빠른 전달 확인
  let hasQuickPass = false;
  for (const doc of passSnap.docs) {
    const data = doc.data();
    if (data.receivedAt && data.timestamp) {
      const received = (data.receivedAt as admin.firestore.Timestamp).toMillis();
      const passed = (data.timestamp as admin.firestore.Timestamp).toMillis();
      const diffMs = passed - received;
      if (diffMs >= 0 && diffMs <= 10 * 60 * 1000) {
        hasQuickPass = true;
        break;
      }
    }
  }

  // 유저 데이터 조회
  const userSnap = await userRef.get();
  const userData = userSnap.data();
  const completedIds: string[] = userData?.completedMissionIds ?? [];
  const ownedItems: Record<string, string[]> = userData?.groupOwnedItemIds ?? {};
  const hasAnyItem = Object.values(ownedItems).some((ids) => ids.length > 0);
  const lootBoxCount: number = userData?.lootBoxCount ?? 0;

  const ctx: MissionContext = { passCount, hasAnyItem, lootBoxCount, hasQuickPass };

  const newlyCompleted: string[] = [];

  for (const mission of MISSIONS) {
    if (completedIds.includes(mission.id)) continue;
    if (mission.check(ctx)) {
      newlyCompleted.push(mission.id);
    }
  }

  if (newlyCompleted.length === 0) return [];

  // 보상 지급 + completedMissionIds 업데이트
  await userRef.update({
    completedMissionIds: admin.firestore.FieldValue.arrayUnion(...newlyCompleted),
    [`groupCurrencies.${groupId}`]: admin.firestore.FieldValue.increment(
      MISSION_REWARD * newlyCompleted.length,
    ),
  });

  functions.logger.info(
    `미션 달성: uid=${uid}, missions=${newlyCompleted.join(',')}`,
  );

  return newlyCompleted;
}

/**
 * pass 로그 생성 시 미션 검사 트리거.
 */
export const onPassCreated = functions.firestore
  .document('groups/{groupId}/passes/{passId}')
  .onCreate(async (snap, context) => {
    const { groupId } = context.params;
    const data = snap.data();
    const fromUid = data.fromUid as string;
    if (!fromUid) return;

    await evaluateMissions(fromUid, groupId);
  });

/**
 * 유저 문서 업데이트 시 아이템 구매 / 뽑기 미션 검사.
 */
export const onUserUpdated = functions.firestore
  .document('users/{uid}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // completedMissionIds 변경이면 재귀 방지
    const beforeCompleted = JSON.stringify(before.completedMissionIds ?? []);
    const afterCompleted = JSON.stringify(after.completedMissionIds ?? []);
    if (beforeCompleted !== afterCompleted) return;

    // groupOwnedItemIds 또는 lootBoxCount 변경 확인
    const itemsChanged =
      JSON.stringify(before.groupOwnedItemIds ?? {}) !==
      JSON.stringify(after.groupOwnedItemIds ?? {});
    const lootBoxChanged =
      (before.lootBoxCount ?? 0) !== (after.lootBoxCount ?? 0);

    if (!itemsChanged && !lootBoxChanged) return;

    const uid = context.params.uid;

    // 아이템이 추가된 그룹 찾기
    const afterOwned: Record<string, string[]> = after.groupOwnedItemIds ?? {};
    const beforeOwned: Record<string, string[]> = before.groupOwnedItemIds ?? {};

    for (const groupId of Object.keys(afterOwned)) {
      const beforeIds = beforeOwned[groupId] ?? [];
      const afterIds = afterOwned[groupId] ?? [];
      if (afterIds.length > beforeIds.length) {
        await evaluateMissions(uid, groupId);
        break;
      }
    }
  });

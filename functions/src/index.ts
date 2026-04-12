import * as admin from 'firebase-admin';

// Firebase Admin 초기화 (Cloud Functions 환경에서 자동 인증)
admin.initializeApp();

// 각 도메인별 함수 export
export * from './bomb/bombExpireScheduler';
export * from './bomb/passBombCallable';
export * from './bomb/explodeBombCallable';
export * from './group/groupTriggers';
export * from './notification/fcmSender';
export * from './items/itemController';
export * from './items/lootBoxController';
export * from './mission/missionController';
export * from './mission/missionTriggers';
export * from './admin/adminCallable';

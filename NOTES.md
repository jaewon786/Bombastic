# 📋 Bombastic 개발 노트

> 팀원 공용 메모판. 결정사항·방향성·논의 내용을 여기에 자유롭게 기록하세요.
> 커밋 메시지보다 덜 형식적으로, 이슈보다 더 빠르게.

## 실행 티켓 (2026-04-12) — 만료/출석/결과 요약 안정화

### TICKET-1 (P0): 게임 만료 스케줄 지연 해소
- 체크리스트
    - [x] `checkGameExpiry` 주기를 60분 → 1분으로 복원
    - [x] 처리 로그가 성공/총 건수로 남는지 확인
- 완료 기준
    - [x] 스케줄 표현이 `every 1 minutes`로 반영됨
    - [x] 코드 리뷰 시 최대 지연 59분 리스크가 제거됨

### TICKET-2 (P0): 결과 summary null-safe 저장 정책 적용
- 체크리스트
    - [x] `memberUids` 누락 시 빈 배열 저장
    - [x] `penaltyCount` 누락 시 빈 객체 저장
    - [x] `expired`/`exploded` 두 경로에 동일 정책 적용
- 완료 기준
    - [x] summary 문서에 `finalizedAt`, `memberUids`, `penaltyCount`, `reason`이 항상 존재
    - [x] group 문서 일부 필드 누락에도 저장 실패 없이 동작

### TICKET-3 (P1): 출석 기준 서버 시간 단일화
- 체크리스트
    - [x] Functions에 `getTodayKey` callable 추가 (Asia/Seoul)
    - [x] 클라이언트에서 서버 todayKey 조회 경로 추가
    - [x] 미션 버튼 비활성 조건을 서버 todayKey 기준으로 전환
- 완료 기준
    - [x] 로컬 디바이스 타임존과 무관하게 서버 판정과 버튼 상태가 일치
    - [x] 자정 경계에서 중복/오판 UX 케이스가 재현되지 않음(수동 검증 예정)

### 실행 순서
1. TICKET-1 코드 반영
2. TICKET-2 코드 반영
3. TICKET-3 코드 반영
4. 정적 검사/빌드 검증

## 최근 업데이트 (2026-04-11) — 변경사항 분석 반영

- 결과 페이지 고도화
    - 랭킹 카드 순차 등장 애니메이션(Fade/Slide) 추가
    - 통계 확장: `passCount` + `maxHoldingMinutes` + `itemUsedCount`
    - 공유 카드 UI 개선 및 랭킹/패스 정보 노출 강화
- 7일 경과 종료 로직 보강
    - `checkGameExpiry` 스케줄러 추가 (1분 주기)
    - `group.gameExpiresAt` 저장/파싱 경로 보강 (Functions + Flutter 모델)
    - `startGame`의 Functions/클라이언트 fallback 경로 모두 `gameExpiresAt` 반영
- 상점 랜덤박스 서버 위임
    - `openLootBox` Callable 추가 (가중치 랜덤 + 재화 차감 + 지급 트랜잭션)
    - 클라이언트 `ShopRepository.purchaseRandomBox`를 Function 호출 방식으로 전환
- 아이템 사용 로그 추가
    - `groups/{groupId}/itemUsages` 기록 및 결과 통계 집계 경로 연동
    - `firestore.rules`에 `itemUsages` 멤버 읽기 규칙 추가
- 알림/런처 반영
    - `FcmService` 신설 (채널 등록/권한 요청/포그라운드 알림/토큰 저장)
    - Android 기본 채널 ID `bombastic_channel` 설정
    - `flutter_native_splash` 설정 및 플랫폼 리소스 반영

## 간단 방향성 메모

### 스크린 구성 및 흐름

```
AuthGate
  └─ 홈 (그룹 목록)
       ├─ 그룹 생성 / 참여코드 입력
       │    └─ 닉네임 설정 (그룹별 1회)
       │         └─ 게임 화면
       │              ├─ [waiting] 대기 UI — 인원 모이는 중 (스플래시 느낌)
       │              └─ [playing] 게임 UI — 인원 충족 시 자동 전환
       └─ 기존 그룹 항목 탭
             └─ 게임 화면 (동일, 현재 상태에 따라 UI 분기)
```

- 홈 화면: 참여 중인 그룹 목록 (그룹 이름 / 내 닉네임 / 간단한 현황 표시)
- 그룹 생성/참여 버튼은 홈 화면에 위치
- 닉네임은 앱 전역이 아닌 **그룹별로 독립 관리**, 참여 시점에 입력
- 대기실은 별도 라우트 없이 게임 화면 내 상태(`waiting`)로 처리
- 다중 그룹 동시 참여 가능 (각 그룹마다 독립적인 게임 진행)

### 기능 설명
- 방장이 그룹 생성 시 **그룹 이름** + **참가 인원(2~10명)** 설정 → 참여코드 공유
- 참여 시 그룹별 닉네임 설정 후 대기, 방장이 설정한 인원이 모두 모이면 게임 자동 시작
    - 이때 참가 인원수의 목록에 대해 고정 폭탄 전달 순서가 생성됨
- 정해진 시간 이내에 사용할 아이템을 적용한 뒤(없으면 생략) 다음 친구에게 폭탄을 전달해야 함, 그러지 못하면 폭탄이 터지며 게임 즉시 종료
- 기본 전제: 친구들끼리 내기를 걸고 한다던지.

### 세부 기능
- 일일 미션으로 앱에 접속하여 출석하거나, 간단한 미션을 통해 재화를 획득
- 재화를 통해 상점에서 아이템 구매 가능(아래는 구상한 아이템 목록), 아니면 그냥 아이템 랜덤상자만 판매하고, 그 상자 내에서 아래 항목 중 하나가 확률별로(사기성 높을수록 낮게) 등장하게 해도 좋을듯
    - 폭탄 전달 순서 섞기(본인의 현재 위치는 유지)
    - 폭탄 전달 제한시간 단축(고정값 또는 유동적 - 이거는 턴 넘기기 전에만 말고 언제든 사용 가능)
    - 폭탄 전달 방향 바꾸기
    - 새 폭탄 생성
    - 폭탄에 패널티 추가
    - 현재 게임 기간 n일 증가/감소
    - 그 외 재미 요소 등
    - 중요: 아이템은 두가지 속성으로 나눔 -> 폭탄을 소유중이며 다음 턴으로 넘기기 전에 사용할 수 있는 아이템 / 폭탄 소유 여부와 상관 없이 사용 가능한 아이템
- 기본 인터페이스에서 현재 어떤 친구가 폭탄을 소유중인지, 폭파까지 남은 시간, 현재 그룹 이름, 참여자 명단 등 기본 정보 출력
- 게임이 정상적으로 종료되면 아래 정보를 포함한 명예의 전당 결과 페이지로 넘어감
    - 재미 및 개그 요소: 가장 폭탄을 많이 토스한 사람 / 가장 폭탄을 오래 홀딩한 사람 / 아이템을 가장 많이 사용한 사람 등...
    - 명예의 전당 결과 영상 등이 끝나면 간단 카드 형식으로 정제하여 SNS 등에 공유를 유도

### 궁극적 목표
- 친한 친구들끼리 우리끼리만의 친밀 커뮤니케이션 도모
- 내기를 건 승부인 만큼 조마조마하며 즐길 수 있게 설계
- 시험기간인 지금! 위의 효과를 통해 직/간접적으로 상대가 계속 폭탄 생각이 나도록 하고, 앱을 키도록 유도하며 공부를 방해하는 것~!
---

## ✅ TODO 리스트

### 🚀 진행 순서 (권장)

1. **환경 설정** — Firebase 프로젝트 생성 → `flutterfire configure` → 플랫폼 파일 배치 → `build_runner` 실행. 이게 끝나야 나머지 모든 작업이 가능.
2. **인증 · 그룹** — 로그인 + 홈 화면 + 그룹 생성/참여 + 닉네임 설정. 앱 진입 흐름 전체가 여기서 완성됨.
3. **백엔드 · 서버** — Firestore 보안 규칙 + Cloud Functions 배포. 2번과 병행 가능, 게임 로직 전에 반드시 완료.
4. **게임 로직** — 폭탄 전달 + 타이머 + 종료 조건 + 아이템 효과. 앱의 핵심, 3번 완료 후 진행.
5. **상점 · 미션** — 재화 시스템 + 상점 방식 결정 후 구현. 4번과 병행 가능.
6. **UI · 디자인** — 결과 페이지 연출 + 공유카드 + 아이콘/스플래시. 전체 흐름이 잡힌 뒤 마무리.

---

### 환경 설정
- [x] Firebase 프로젝트 생성 및 팀원 초대
- [x] `flutterfire configure` 실행 후 각자 `firebase_options.dart` 생성
- [x] `google-services.json` / `GoogleService-Info.plist` 배치
- [x] `dart run build_runner build` 실행 (freezed / riverpod 코드 생성)
- [ ] CI 구성 검토 (GitHub Actions + flutter test)

### 인증 · 그룹
- [x] 익명 로그인 완성 (AuthController → UserModel Firestore 저장)
- [x] AuthGate — 로그인 상태 실시간 감지 및 홈 화면 라우팅 연동
- [x] 홈 화면 구현 — 참여 중인 그룹 목록뷰 (그룹명 / 내 닉네임 / 간단 현황)
- [x] 그룹 생성 / 참여코드 입력 화면 구현
- [x] 그룹 참여 시점에 그룹별 닉네임 입력 화면 추가 (`NicknameInputPage`, `/group/:groupId/nickname`)
- [x] 다중 그룹 참여 지원 — `UserModel`에 `groupIds` 리스트 + `groupNicknames` 맵 추가
- [x] 대기실 별도 라우트 제거 — 게임 화면 내 `waiting` 상태 UI로 처리 (`_WaitingView`)
- [x] 대기실 상태 — 방장 권한 판단 (첫 번째 memberUid)
- [x] 중도 이탈 불가 처리 (`PopScope` + `_showExitBlockedDialog`)
- [x] `UserRepository` 신설 — `watchUser`, `setUser`, `addGroupMembership`, `updateGroupNickname`, `removeGroupMembership`
- [x] `currentUserProvider` 추가 (`firebase_providers.dart`, 현재 유저 Firestore 실시간 스트림)
- [x] 그룹 생성자 닉네임 입력 — 그룹 생성 후 닉네임 입력 화면으로 이동하도록 변경
- [x] 중복 참여 방지 — `joinGroup`에서 중복 멤버/정원 초과를 트랜잭션으로 검증
- [x] 참여코드 생성 클라이언트 유지 — 서버 `createGroup`에서 `already-exists` 검증 + 클라이언트 1회 재시도

### 백엔드 · 서버
- [x] `startGame` Callable Function 추가 — 방장 전용, 최소 2명 확인 후 폭탄 생성 + 그룹 상태 `playing` 전환
- [x] `onGroupMemberJoined` 트리거 — 고정 4명 조건 → `maxMembers` 동적 비교로 수정
- [x] Firestore 보안 규칙 파일 생성 (`firestore.rules`) — 내용은 아직 미완성
- [x] Firestore `shopItems` 시드 스크립트 추가 (`functions/src/seeds/`)
- [ ] Cloud Functions 배포 및 에뮬레이터 테스트
- [ ] `checkBombExpiry` 스케줄러 동작 확인 (1분 주기)
- [x] `firestore.rules` 보안 규칙 완성
- [x] `startGame` Function의 폭탄 만료 시간 하드코딩 제거 — Functions 공통 설정(`BOMB_DEFAULT_DURATION_SECONDS`, 기본 86400초)으로 동기화
- [x] FCM 채널 ID 통일 (`bombastic_channel`) — Android 기본 채널 + 클라이언트 채널 생성 반영

### 게임 로직
- [x] `passBomb` — `memberUids` 인덱스 기반 순환 로직 구현, groupId 연결 완료
- [x] `activeBombProvider` / `isMyTurnProvider` — groupId 파라미터로 전환 (family provider)
- [x] `GamePage` — `groupId` 수신 후 `GroupStatus`에 따라 `_WaitingView` / `_PlayingView` / `_FinishedView` 분기
- [x] `watchGroupProvider` 추가 (groupId 파라미터) — 기존 `currentGroupProvider` 대체
- [x] `_PlayingView` 게임 화면 정보 보완 — 현재 폭탄 보유자 닉네임 / 그룹 이름 / 참여자 명단 표시
- [x] 7일 경과 정상 종료 처리 — `checkGameExpiry` + `gameExpiresAt` 저장/파싱 경로 반영
- [x] 아이템 속성 분리 구현: ① 폭탄 보유 중 전용 / ② 상시 사용 가능
- [x] 아이템 효과 구현 (순서 섞기, 방향 바꾸기, 제한시간 단축, 폭탄 추가, 패널티 추가, 게임 기간 n일 증감 등)
- [x] 아이템 사용 UI — 인벤토리/사용 버튼 구현
- [ ] 미션 완료 판단 트리거 — `isCompleted` 항상 `false`, 달성 검증 로직 없음
- [ ] 출석 체크 중복 방지 확인 (서버타임스탬프 기준)

### 상점 · 미션
- [ ] 상점 방식 결정 후 구현 → 랜덤박스 서버 위임 구현 완료, 개별 구매/정책 확정은 미결
- [ ] 재화 잔액 실시간 표시 (UserModel 스트림 → AppBar 배지)

### 결과 페이지
- [x] `gameResult` provider — groupId 파라미터로 전환, 그룹 닉네임 맵 사용, 폭발 0회 멤버 포함
- [x] `ResultPage` — groupId 수신 파라미터 추가, 라우트 `/result/:groupId`로 변경
- [x] `share_plus` 연동 — `Share.shareXFiles`로 결과 이미지 실제 공유 구현
- [x] `passCount` 집계 구현 — `groups/{id}/passes` 로그 기반으로 결과 페이지 반영

### UI · 디자인
- [x] 대기실 UI — 참여 코드 표시, 참여자 목록 (닉네임 + 방장 뱃지), 방장 게임 시작 버튼 (2명 이상 시 활성화)
- [x] 게임 화면 (`_PlayingView`) 기본 정보 표시 — 현재 폭탄 보유자 / 남은 시간 / 그룹 이름 / 참여자 명단
- [x] 결과 페이지 등장 연출/애니메이션 구현 (명예의 전당 순위 공개 효과)
- [x] 결과 페이지 통계 추가 (최다 토스 / 최장 홀딩 / 아이템 최다 사용)
- [x] 공유카드 디자인 고도화 (`ResultShareCard`) + SNS 공유 UX 개선
- [ ] 앱 아이콘 / 스플래시 스크린 (`flutter_native_splash`) — 스플래시 반영 완료, 앱 아이콘은 별도 작업 필요
- [x] 다크모드 대응 확인 (`AppTheme.dark` 구현 완료)

### 🎯 다음 실행 백로그 Top 5

| 우선순위 | 작업 | 범주 | 담당 | 예상 소요 | 완료 기준 |
|---|---|---|---|---|---|
| P0 | `joinGroup` 중복 참여 방지 | 인증 · 그룹 | 완료 | 0.5일 | 동일 uid 중복 가입이 불가능하고 회귀 테스트 케이스 확인 |
| P0 | `firestore.rules` 보안 규칙 완성 | 백엔드 · 서버 | 완료 | 1일 | 그룹/폭탄/유저 문서에 대해 읽기/쓰기 권한 시나리오 검증 완료 |
| P0 | Cloud Functions 에뮬레이터 테스트 + 배포 점검 | 백엔드 · 서버 | 미정 | 1일 | `startGame`, `useItem`, 스케줄러 핵심 경로가 로컬에서 재현되고 배포 체크리스트 통과 |
| P1 | 7일 경과 정상 종료 처리 정책 및 구현 | 게임 로직 | 미정 | 1일 | 폭발 종료 외 기간 만료 종료가 일관되게 반영되고 결과 페이지로 연결 |
| P1 | 결과 페이지 통계 확장 (최장 홀딩/아이템 최다 사용) | UI · 디자인/결과 | 미정 | 1일 | 추가 통계 2개 이상 집계되어 랭킹/카드에 노출 |

---

## 🐛 코드 레벨 버그 / 주의 사항

> 코드 리뷰 중 발견한 잠재적 버그 및 불일치. TODO 리스트와 달리 **지금 당장 고쳐야 하거나** 방치 시 데이터 오염이 생기는 항목 위주.

| 파일 | 문제 | 수정 방향 |
|------|------|-----------|
| `group_repository.dart:59` | 해결됨: `joinGroup`이 트랜잭션에서 중복 멤버 및 정원 초과를 검증하도록 수정됨 | 후속: Functions 경유 가입으로 완전 서버 권한화 검토 |
| `group_controller.dart:28` | 해결됨: 그룹 생성 후 닉네임 입력 화면(`/group/:groupId/nickname`)으로 이동하도록 수정됨 | 후속: 그룹 내 설정에서 닉네임 변경 기능 추가 |
| `bombExpireScheduler.ts` (`onBombExploded`) | 해결됨: 주석 표현을 실제 동작(폭발 즉시 종료)과 일치하게 수정 | 7일 경과 종료는 `checkGameExpiry`가 별도 처리 |
| `mission_repository.dart` | `MissionModel.isCompleted` 항상 `false` — 미션 달성 여부를 Firestore에 기록하거나 판단하는 로직 없음 | 미션별 달성 조건 정의 및 트리거 구현 전까지 UI에서 완료 표시 불가 |
| `result_controller.dart` | 해결됨: `passCount` + `maxHoldingMinutes` + `itemUsedCount` 집계 반영됨 | 후속: 통계 정확도 회귀 테스트 추가 권장 |
| `groupTriggers.ts` (`startGame`) | 해결됨: 폭탄 만료 시간이 Functions 공통 설정(`BOMB_DEFAULT_DURATION_SECONDS`)을 사용하도록 변경됨 | 후속: Flutter `AppConstants.defaultBombDurationSeconds`와 운영 환경값 문서화 |

---

## 🔀 개발 방향성 & 결정 사항

### 아키텍처
- **단방향 데이터 흐름**: Firestore onSnapshot → Repository Stream → Riverpod Provider → UI
- **쓰기는 Cloud Functions 우선**: 폭탄 생성·폭발처럼 무결성이 중요한 쓰기는 클라이언트 직접 쓰기 금지, Functions Callable or Trigger 경유
- **로컬 상태 최소화**: 타이머조차 `expiresAt` 서버값 기준으로 계산 (클라이언트 조작 방지)

### 네이밍 컨벤션
- Provider: `xxxProvider` (Riverpod @riverpod 자동 생성)
- Controller: `XxxController extends _$XxxController`
- Model: `XxxModel` (freezed)
- Page: `XxxPage` (ConsumerWidget or ConsumerStatefulWidget)
- Repository: `XxxRepository`

### 브랜치 전략
```
main        ← 배포 가능한 상태만
develop     ← 통합 브랜치
feat/A-xxx  ← 기능 브랜치 (담당자/작업명)
fix/xxx     ← 버그 수정
```

### 커밋 메시지
```
feat(game): 폭탄 전달 로직 구현
fix(group): 참여코드 중복 체크 누락 수정
chore: build_runner 생성 파일 제외
```

---

## ❓ 미결 사항

| # | 주제 | 비고 |
|---|------|------|
| 6 | **진동/알람 세기** | 각 알림 파트 개발 시점에 개별 결정 |
| 7 | **상점 방식** | ~~결정 필요~~ → **랜덤박스 방식으로 확정** (`openLootBox` Callable Function 구현 완료) |

---

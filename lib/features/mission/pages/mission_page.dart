import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/firebase/firebase_providers.dart';
import '../controllers/mission_controller.dart';

/// 탭에서 직접 사용하는 미션 body 위젯
class MissionBody extends ConsumerWidget {
  const MissionBody({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionsAsync = ref.watch(missionsProvider);
    final checkInState = ref.watch(missionControllerProvider);
    final currentUser = ref.watch(currentUserProvider).asData?.value;
    final serverTodayKeyAsync = ref.watch(serverTodayKeyProvider);
    final lastCheckIn = currentUser?.lastCheckInDate;
    final lastCheckInKey = lastCheckIn == null
      ? null
      : '${lastCheckIn.year.toString().padLeft(4, '0')}-${lastCheckIn.month.toString().padLeft(2, '0')}-${lastCheckIn.day.toString().padLeft(2, '0')}';
    final serverTodayKey = serverTodayKeyAsync.asData?.value;
    final alreadyCheckedIn =
      serverTodayKey != null && lastCheckInKey == serverTodayKey;
    final isCheckInButtonDisabled =
      checkInState.isLoading || alreadyCheckedIn || serverTodayKey == null;

    return Column(
      children: [
        // 출석 체크 섹션
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('오늘의 출석 체크', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 4),
                Text(
                  '출석 보상은 이 그룹의 재화로 지급됩니다.',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: isCheckInButtonDisabled
                      ? null
                      : () async {
                          await ref
                              .read(missionControllerProvider.notifier)
                              .checkIn(groupId: groupId);
                          if (!context.mounted) return;
                          final err =
                              ref.read(missionControllerProvider).error;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                err != null
                                    ? '$err'
                                    : '출석 완료! +${CurrencyConstants.dailyCheckInReward}💰',
                              ),
                            ),
                          );
                        },
                  icon: Icon(alreadyCheckedIn
                      ? Icons.check_circle
                      : Icons.check_circle_outline),
                  label: Text(alreadyCheckedIn
                      ? '오늘 출석 완료 \u2713'
                      : '출석하기 (+${CurrencyConstants.dailyCheckInReward}💰)'),
                ),
                if (serverTodayKeyAsync.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '서버 시간 확인 중...',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // 미션 목록
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '미션 목록',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: missionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('오류: $e')),
            data: (missions) => ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: missions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final mission = missions[i];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      mission.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: mission.isCompleted ? Colors.green : null,
                    ),
                    title: Text(mission.title),
                    subtitle: Text(mission.description),
                    trailing: Text('💰 ${mission.reward}'),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

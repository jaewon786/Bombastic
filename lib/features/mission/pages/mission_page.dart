import 'package:bomb_pass/core/constants/app_constants.dart';
import 'package:bomb_pass/data/firebase/firebase_providers.dart';
import 'package:bomb_pass/features/mission/controllers/mission_controller.dart';
import 'package:bomb_pass/widgets/currency_icon.dart';
import 'package:bomb_pass/core/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 탭에서 직접 사용하는 미션 body 위젯
class MissionBody extends ConsumerStatefulWidget {
  const MissionBody({required this.groupId, super.key});

  final String groupId;

  @override
  ConsumerState<MissionBody> createState() => _MissionBodyState();
}

class _MissionBodyState extends ConsumerState<MissionBody> {
  /// 출석 성공 시 즉시 UI 반영용 로컬 플래그
  bool _justCheckedIn = false;

  @override
  Widget build(BuildContext context) {
    final groupId = widget.groupId;
    final missionsAsync = ref.watch(missionsProvider(groupId));
    final checkInState = ref.watch(missionControllerProvider);
    final serverTodayKeyAsync = ref.watch(serverTodayKeyProvider);
    final lastCheckInKey = ref.watch(lastCheckInDateProvider(groupId));
    final serverTodayKey = serverTodayKeyAsync.asData?.value;
    final alreadyCheckedIn = _justCheckedIn ||
        (serverTodayKey != null &&
            lastCheckInKey != null &&
            lastCheckInKey == serverTodayKey);
    final isCheckInButtonDisabled =
        checkInState.isLoading || alreadyCheckedIn || serverTodayKey == null;
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor:
          alreadyCheckedIn ? const Color(0xFF2E7D32) : const Color(0xFFFFC94A),
      foregroundColor:
          alreadyCheckedIn ? Colors.white : const Color(0xFF4E342E),
      disabledBackgroundColor:
          alreadyCheckedIn ? const Color(0xFF2E7D32) : const Color(0xFFFFECB3),
      disabledForegroundColor:
          alreadyCheckedIn ? Colors.white : const Color(0xFF8D6E63),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );

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
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: buttonStyle,
                  onPressed: isCheckInButtonDisabled
                      ? null
                      : () async {
                          final success = await ref
                              .read(missionControllerProvider.notifier)
                              .checkIn(groupId: groupId);
                          if (!mounted) return;
                          final err =
                              ref.read(missionControllerProvider).error;
                          final String message;
                          if (err != null) {
                            message = '출석 체크에 실패했습니다.';
                          } else if (success) {
                            setState(() => _justCheckedIn = true);
                            ref.read(audioServiceProvider).playSfx('MoneyCollectingSound1.mp3');
                            message =
                                '출석 완료! +${CurrencyConstants.dailyCheckInReward}💰';
                          } else {
                            setState(() => _justCheckedIn = true);
                            message = '오늘은 이미 출석했습니다.';
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        },
                  icon: checkInState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : alreadyCheckedIn
                          ? const Icon(Icons.check_circle)
                          : const CurrencyIcon(),
                  label: Text(
                    alreadyCheckedIn
                        ? '출석 완료'
                        : '출석하기 (+${CurrencyConstants.dailyCheckInReward})',
                  ),
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

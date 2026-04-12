import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/firebase/firebase_providers.dart';
import '../../../../data/repositories/bomb_repository.dart';
import '../../../group/controllers/group_controller.dart';

part 'log_tab.g.dart';

@riverpod
Stream<List<Map<String, dynamic>>> passLogs(Ref ref, String groupId) {
  return ref.watch(bombRepositoryProvider).watchPassLogs(groupId);
}

@riverpod
Stream<List<Map<String, dynamic>>> itemUsageLogs(Ref ref, String groupId) {
  if (groupId.isEmpty) return const Stream.empty();
  return ref
      .watch(firestoreProvider)
      .collection('groups')
      .doc(groupId)
      .collection('itemUsages')
      .orderBy('usedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => d.data()).toList());
}

class LogTab extends ConsumerWidget {
  const LogTab({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passLogsAsync = ref.watch(passLogsProvider(groupId));
    final itemLogsAsync = ref.watch(itemUsageLogsProvider(groupId));
    final group = ref.watch(watchGroupProvider(groupId)).asData?.value;
    final nicknames = group?.memberNicknames ?? {};

    final passLogs = passLogsAsync.asData?.value ?? const [];
    final itemLogs = itemLogsAsync.asData?.value ?? const [];

    if (passLogsAsync.isLoading && itemLogsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 통합 로그: 각 항목에 'logType' 추가
    final combined = <Map<String, dynamic>>[
      for (final log in passLogs) {...log, '_logType': 'pass'},
      for (final log in itemLogs) {...log, '_logType': 'item'},
    ];

    // 시간 기준 정렬 (최신순)
    combined.sort((a, b) {
      final tsA = a['timestamp'] ?? a['usedAt'];
      final tsB = b['timestamp'] ?? b['usedAt'];
      if (tsA is Timestamp && tsB is Timestamp) {
        return tsB.compareTo(tsA);
      }
      return 0;
    });

    if (combined.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📋', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('아직 기록이 없습니다.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // 날짜별 그룹핑
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final log in combined) {
      final ts = log['timestamp'] ?? log['usedAt'];
      DateTime? dt;
      if (ts is Timestamp) dt = ts.toDate().toLocal();
      final dateKey = dt != null
          ? '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}'
          : '날짜 없음';
      grouped.putIfAbsent(dateKey, () => []).add(log);
    }

    final dateKeys = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: dateKeys.length,
      itemBuilder: (_, i) {
        final date = dateKeys[i];
        final entries = grouped[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const Divider(height: 1),
            ...entries.map((log) {
              final ts = log['timestamp'] ?? log['usedAt'];
              DateTime? dt;
              if (ts is Timestamp) dt = ts.toDate().toLocal();
              final timeStr = dt != null
                  ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
                  : '--:--';

              final logType = log['_logType'] as String;

              if (logType == 'item') {
                final uid = log['uid'] as String? ?? '';
                final nick = nicknames[uid] ?? uid;
                final itemType = log['itemType'] as String? ?? '';
                final desc = _itemTypeLabel(itemType);
                return ListTile(
                  dense: true,
                  leading: Text(
                    timeStr,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  title: Text(
                    '$nick님이 $desc을(를) 사용했습니다.',
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: Icon(
                    _itemTypeIcon(itemType),
                    size: 16,
                    color: Colors.purple.shade300,
                  ),
                );
              }

              final fromUid = log['fromUid'] as String? ?? '';
              final toUid = log['toUid'] as String? ?? '';
              final fromNick = nicknames[fromUid] ?? fromUid;
              final toNick = nicknames[toUid] ?? toUid;

              return ListTile(
                dense: true,
                leading: Text(
                  timeStr,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                title: Text(
                  '$fromNick님이 $toNick님에게 폭탄을 전달했습니다.',
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: Colors.red.shade300,
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

String _itemTypeLabel(String itemType) {
  return switch (itemType) {
    'swapOrder' => '순서 셔플',
    'reverseDirection' => '방향 반전',
    'shrinkDuration' => '타이머 단축',
    'guardianAngel' => '수호천사',
    _ => '아이템',
  };
}

IconData _itemTypeIcon(String itemType) {
  return switch (itemType) {
    'swapOrder' => Icons.shuffle_rounded,
    'reverseDirection' => Icons.swap_horiz_rounded,
    'shrinkDuration' => Icons.hourglass_bottom_rounded,
    'guardianAngel' => Icons.shield_rounded,
    _ => Icons.inventory_2,
  };
}

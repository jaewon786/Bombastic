import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'credits_controller.g.dart';

class CreditsAwardData {
  const CreditsAwardData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.winners,
    this.isLoser = false,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final List<String> winners;
  final bool isLoser;

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'title': title,
        'subtitle': subtitle,
        'winners': winners,
        'isLoser': isLoser,
      };

  factory CreditsAwardData.fromJson(Map<String, dynamic> json) =>
      CreditsAwardData(
        emoji: json['emoji'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        winners: List<String>.from(json['winners'] as List),
        isLoser: json['isLoser'] as bool? ?? false,
      );
}

class CreditsSnapshotData {
  const CreditsSnapshotData({
    required this.groupName,
    required this.nicknames,
    required this.awards,
  });

  final String groupName;
  final List<String> nicknames;
  final List<CreditsAwardData> awards;
}

/// 그룹별 엔딩 크레딧 최초 1회 재생 여부 (SharedPreferences 영속)
@riverpod
class CreditsShown extends _$CreditsShown {
  late final String _groupId;

  @override
  Future<bool> build(String groupId) async {
    _groupId = groupId;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('credits_shown_$groupId') ?? false;
  }

  /// 크레딧을 봤음으로 영구 기록
  Future<void> markShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('credits_shown_$_groupId', true);
    state = const AsyncData(true);
  }

  /// 다시보기 — SharedPreferences는 유지, 현 세션만 재생
  void showAgain() {
    state = const AsyncData(false);
  }

  /// 첫 재생 시점의 그룹명·닉네임·어워드를 저장
  Future<void> saveSnapshot(
    String groupName,
    List<String> nicknames,
    List<CreditsAwardData> awards,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode({
      'name': groupName,
      'nicknames': nicknames,
      'awards': awards.map((a) => a.toJson()).toList(),
    });
    await prefs.setString('credits_snapshot_$_groupId', encoded);
  }

  /// 저장된 스냅샷 로드 (없으면 null)
  Future<CreditsSnapshotData?> loadSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('credits_snapshot_$_groupId');
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final awards = (map['awards'] as List?)
            ?.map((a) =>
                CreditsAwardData.fromJson(a as Map<String, dynamic>))
            .toList() ??
        [];
    return CreditsSnapshotData(
      groupName: map['name'] as String,
      nicknames: List<String>.from(map['nicknames'] as List),
      awards: awards,
    );
  }
}

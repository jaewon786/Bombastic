import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

class AudioService {
  final _bgmPlayer = AudioPlayer();
  final _tickingPlayer = AudioPlayer();
  
  AudioService() {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _tickingPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> dispose() async {
    await _bgmPlayer.dispose();
    await _tickingPlayer.dispose();
  }

  /// 1회성 효과음 재생 (다수 중첩 가능)
  Future<void> playSfx(String fileName) async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/$fileName'));
      
      // 재생 완료 시 플레이어 자원 해제
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      debugPrint('playSfx Error: $e');
    }
  }

  /// 반복되는 BGM 재생
  Future<void> playBgm(String fileName) async {
    try {
      await _bgmPlayer.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      debugPrint('playBgm Error: $e');
    }
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint('stopBgm Error: $e');
    }
  }

  /// 긴장감 넘치는 Ticking 재생
  Future<void> playTicking() async {
    try {
      if (_tickingPlayer.state != PlayerState.playing) {
        await _tickingPlayer.play(AssetSource('sounds/WatchTickingSound1.mp3'));
      }
    } catch (e) {
      debugPrint('playTicking Error: $e');
    }
  }

  Future<void> stopTicking() async {
    try {
      await _tickingPlayer.stop();
    } catch (e) {
      debugPrint('stopTicking Error: $e');
    }
  }
}

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

  String? _currentBgmFile;
  double _currentBgmVolume = 0.05;

  AudioService() {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _tickingPlayer.setReleaseMode(ReleaseMode.loop);
    _bgmPlayer.setVolume(0.05);
    _tickingPlayer.setVolume(0.05);
  }

  Future<void> dispose() async {
    await _bgmPlayer.dispose();
    await _tickingPlayer.dispose();
  }

  /// 1회성 효과음 재생 (다수 중첩 가능)
  Future<void> playSfx(String fileName) async {
    try {
      final player = AudioPlayer();
      await player.setVolume(0.05);
      await player.play(AssetSource('sounds/$fileName'));
      
      // 재생 완료 시 플레이어 자원 해제
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      debugPrint('playSfx Error: $e');
    }
  }

  /// 반복되는 BGM 재생 (기본 5%)
  Future<void> playBgm(String fileName, {double volume = 0.05}) async {
    try {
      _currentBgmFile = fileName;
      _currentBgmVolume = volume;
      if (_bgmPlayer.state == PlayerState.playing) {
        await _bgmPlayer.stop();
      }
      await _bgmPlayer.setVolume(volume);
      await _bgmPlayer.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      debugPrint('playBgm Error: $e');
    }
  }

  /// BGM이 멈춰있으면 마지막 파일로 재시작 (탭 전환 후 복구용)
  Future<void> ensureBgmPlaying() async {
    try {
      if (_currentBgmFile == null) return;
      if (_bgmPlayer.state == PlayerState.playing) return;
      await _bgmPlayer.setVolume(_currentBgmVolume);
      await _bgmPlayer.play(AssetSource('sounds/$_currentBgmFile'));
    } catch (e) {
      debugPrint('ensureBgmPlaying Error: $e');
    }
  }

  /// 현재 재생중인 BGM의 볼륨만 조절 (음소거/복구용)
  Future<void> changeBgmVolume(double volume) async {
    try {
      await _bgmPlayer.setVolume(volume);
    } catch (e) {
      debugPrint('changeBgmVolume Error: $e');
    }
  }

  Future<void> stopBgm() async {
    try {
      _currentBgmFile = null;
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint('stopBgm Error: $e');
    }
  }

  /// 모든 오디오 일시정지 (앱 백그라운드용)
  Future<void> pauseAll() async {
    try {
      await _bgmPlayer.pause();
      await _tickingPlayer.pause();
    } catch (e) {
      debugPrint('pauseAll Error: $e');
    }
  }

  /// 모든 오디오 재개 (앱 포그라운드용)
  Future<void> resumeAll() async {
    try {
      await _bgmPlayer.resume();
      await _tickingPlayer.resume();
    } catch (e) {
      debugPrint('resumeAll Error: $e');
    }
  }

  /// 긴장감 넘치는 Ticking 재생
  Future<void> playTicking() async {
    try {
      if (_tickingPlayer.state != PlayerState.playing) {
        await _tickingPlayer.setVolume(0.05);
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

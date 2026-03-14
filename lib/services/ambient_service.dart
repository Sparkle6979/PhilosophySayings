import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AmbientService — 全局单例，管理背景环境音的播放状态和音量。
/// 继承 ChangeNotifier 以便 UI 能实时响应状态变化。
class AmbientService extends ChangeNotifier {
  AmbientService._internal();
  static final AmbientService instance = AmbientService._internal();

  static const String _audioAsset = 'audio/background.mp3';
  static const String _prefEnabled = 'ambient_enabled';
  static const String _prefVolume = 'ambient_volume';
  static const double _defaultVolume = 0.3;

  final AudioPlayer _player = AudioPlayer();
  bool _isEnabled = false;
  double _volume = _defaultVolume;
  bool _initialized = false;

  bool get isEnabled => _isEnabled;
  double get volume => _volume;

  /// 初始化：从持久化配置中读取状态。应在 main() 中调用一次。
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_prefEnabled) ?? false;
      _volume = prefs.getDouble(_prefVolume) ?? _defaultVolume;
      
      await _player.setVolume(_volume);
      await _player.setReleaseMode(ReleaseMode.loop);
      
      if (_isEnabled && !kIsWeb) {
        // 非 Web 端可以尝试直接播放，Web 端需等待用户交互
        await _player.play(AssetSource(_audioAsset));
      }
    } catch (e) {
      debugPrint("AmbientService init error: $e");
    }
  }

  /// 切换开关状态。
  Future<void> toggle() async {
    await setEnabled(!_isEnabled);
  }

  /// 设置开启/关闭。
  Future<void> setEnabled(bool enabled) async {
    if (_isEnabled == enabled) return;
    _isEnabled = enabled;
    notifyListeners(); // 立即通知 UI 更新开关状态
    
    // 关键修复：Web 浏览器要求用户手势后的**同一个**事件循环中触发音频播放。
    // 如果先 await _persist()，异步等待会丢失用户操作上下文，导致浏览器拦截。
    try {
      if (_isEnabled) {
        _player.play(AssetSource(_audioAsset)); // Fire and forget (sync trigger)
      } else {
        _player.pause();
      }
    } catch (e) {
      debugPrint("AmbientService audio play error: $e");
    }
    
    try {
      await _persist();
    } catch (e) {
      debugPrint("AmbientService persist error: $e");
    }
  }

  /// 设置音量（0.0 ~ 1.0）。
  Future<void> setVolume(double volume) async {
    final oldVolume = _volume;
    _volume = volume.clamp(0.0, 1.0);
    if (oldVolume == _volume) return;
    
    notifyListeners(); // 立即通知 UI 移动滑块
    
    try {
      await _player.setVolume(_volume);
      await _persist();
    } catch (e) {
      debugPrint("AmbientService setVolume error: $e");
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabled, _isEnabled);
    await prefs.setDouble(_prefVolume, _volume);
  }
}

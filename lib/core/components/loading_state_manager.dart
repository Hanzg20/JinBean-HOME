import 'package:flutter/foundation.dart';
import 'dart:async';
import '../utils/app_logger.dart';

/// 加载状态枚举
enum LoadingStateType {
  initial,   // 初始状态
  loading,   // 加载中
  success,   // 成功
  error,     // 错误
  offline,   // 离线
}

/// 加载状态管理器 - 简化版本
class LoadingStateManager extends ChangeNotifier {
  LoadingStateType _state = LoadingStateType.initial;
  String _errorMessage = '';
  bool _isOnline = true;
  Timer? _retryTimer;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  LoadingStateType get state => _state;
  String get errorMessage => _errorMessage;
  bool get isOnline => _isOnline;
  int get retryCount => _retryCount;

  void setLoading() {
    if (_state != LoadingStateType.loading) {
      _state = LoadingStateType.loading;
      _errorMessage = '';
      notifyListeners();
    }
  }

  void setSuccess() {
    if (_state != LoadingStateType.success) {
      _state = LoadingStateType.success;
      _errorMessage = '';
      _retryCount = 0;
      _retryTimer?.cancel();
      notifyListeners();
    }
  }

  void setError(String message) {
    if (_state != LoadingStateType.error || _errorMessage != message) {
      _state = LoadingStateType.error;
      _errorMessage = message;
      notifyListeners();
    }
  }

  void setOffline() {
    if (_state != LoadingStateType.offline) {
      _state = LoadingStateType.offline;
      _isOnline = false;
      notifyListeners();
    }
  }

  void setOnline() {
    if (!_isOnline) {
      _isOnline = true;
      if (_state == LoadingStateType.offline) {
        _state = LoadingStateType.initial;
      }
      notifyListeners();
    }
  }

  Future<void> retry(Future<void> Function() operation) async {
    if (_retryCount >= _maxRetries) {
      setError('重试次数已达上限，请稍后重试');
      return;
    }

    _retryCount++;
    setLoading();

    try {
      await operation();
      setSuccess();
    } catch (e) {
      setError(e.toString());
      
      // 自动重试
      if (_retryCount < _maxRetries) {
        _retryTimer?.cancel();
        _retryTimer = Timer(
          Duration(seconds: _retryCount * 2), // 递增延迟
          () => retry(operation),
        );
      }
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }
} 
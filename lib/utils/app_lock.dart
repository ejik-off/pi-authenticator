/*
  App Lock для privacyIDEA Authenticator (форк)

  Требует биометрию при каждом запуске приложения и при возврате
  из фона (если прошло больше relockAfter секунд).

  Licensed under the Apache License, Version 2.0
*/

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class AppLockService with WidgetsBindingObserver {
  AppLockService._();
  static final AppLockService instance = AppLockService._();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Блокировка включена. Автоматически отключается,
  /// если на устройстве не настроена биометрия (защита от полной блокировки).
  bool enabled = true;

  /// Через сколько секунд после сворачивания снова запрашивать биометрию.
  Duration relockAfter = const Duration(seconds: 15);

  bool _unlocked = false;
  DateTime? _pausedAt;
  VoidCallback? _onStateChanged;

  bool get isLocked => enabled && !_unlocked;

  void init() {
    WidgetsBinding.instance.addObserver(this);
    _checkBiometricsAvailability();
  }

  Future<void> _checkBiometricsAvailability() async {
    try {
      final biometrics = await _auth.getAvailableBiometrics();
      if (biometrics.isEmpty) {
        // На устройстве нет биометрии — не блокируем,
        // иначе пользователь не сможет войти в приложение.
        enabled = false;
        _notify();
      }
    } catch (_) {
      // Не удалось проверить — оставляем блокировку включённой.
    }
  }

  void addListener(VoidCallback cb) => _onStateChanged = cb;

  void removeListener() => _onStateChanged = null;

  void _notify() {
    final cb = _onStateChanged;
    if (cb != null) cb();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!enabled) return;
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _pausedAt = DateTime.now();
        _unlocked = false;
        _notify();
        break;
      case AppLifecycleState.resumed:
        final paused = _pausedAt;
        if (paused != null &&
            DateTime.now().difference(paused) > relockAfter) {
          _unlocked = false;
          _notify();
        }
        break;
      default:
        break;
    }
  }

  Future<bool> authenticate() async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Разблокируйте privacyIDEA Authenticator',
        options: AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      if (ok) {
        _unlocked = true;
        _notify();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }
}

/// Обёртка: пока приложение заблокировано, показывает экран блокировки
/// вместо основного интерфейса.
class AppLockGate extends StatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> {
  @override
  void initState() {
    super.initState();
    AppLockService.instance.addListener(_rebuild);
    // Запрашиваем биометрию сразу при старте приложения:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AppLockService.instance.isLocked) {
        AppLockService.instance.authenticate();
      }
    });
  }

  @override
  void dispose() {
    AppLockService.instance.removeListener();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!AppLockService.instance.isLocked) return widget.child;
    return Material(
      color: const Color(0xFF121212),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 64,
                color: Color(0xFF4FC3F7),
              ),
              const SizedBox(height: 24),
              const Text(
                'Приложение заблокировано',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => AppLockService.instance.authenticate(),
                icon: const Icon(Icons.fingerprint),
                label: const Text('Разблокировать'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

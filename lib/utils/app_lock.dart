// lib/utils/app_lock.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';

/// Требует биометрию при каждом запуске приложения и при возврате
/// из фона (если прошло больше relockAfter секунд).
class AppLockService with WidgetsBindingObserver {
  AppLockService._();
  static final AppLockService instance = AppLockService._();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Поставьте false, если захотите временно отключить блокировку.
  bool enabled = true;

  /// Через сколько секунд после сворачивания снова спрашивать биометрию.
  Duration relockAfter = const Duration(seconds: 15);

  bool _unlocked = false;
  DateTime? _pausedAt;
  VoidCallback? _onStateChanged;

  bool get isLocked => enabled && !_unlocked;

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Подписка для виджета-обёртки, чтобы перерисовываться.
  void addListener(VoidCallback cb) => _onStateChanged = cb;
  void removeListener() => _onStateChanged = null;

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

  void _notify() {
    final cb = _onStateChanged;
    if (cb != null) cb();
  }

  Future<bool> authenticate() async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Разблокируйте privacyIDEA Authenticator',
        options: const AuthenticationOptions(
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

/// Обёртка-виджет: пока isLocked == true, показывает LockScreen.
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
    // Первая разблокировка при старте приложения:
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
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: const Color(0xFF121212),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline,
                  size: 64, color: Color(0xFF4FC3F7)),
              const SizedBox(height: 24),
              const Text('Приложение заблокировано',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
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

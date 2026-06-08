// ════════════════════════════════════════════════════════════
//  AppEnv  —  Environment configuration
//  غيّر [_env] بين dev / staging / prod
// ════════════════════════════════════════════════════════════
enum _Env { dev, staging, prod }

class AppEnv {
  // ── اختر البيئة هنا ──────────────────────────────────────
  static const _Env _env = _Env.dev;

  // ── Base URLs ────────────────────────────────────────────
  static const String _devUrl     = 'https://api-dev.expocore.app/api/v1';
  static const String _stagingUrl = 'https://api-staging.expocore.app/api/v1';
  static const String _prodUrl    = 'https://api.expocore.app/api/v1';

  static String get baseUrl {
    switch (_env) {
      case _Env.dev:     return _devUrl;
      case _Env.staging: return _stagingUrl;
      case _Env.prod:    return _prodUrl;
    }
  }

  // ── Flags ────────────────────────────────────────────────
  static bool get isDev     => _env == _Env.dev;
  static bool get isStaging => _env == _Env.staging;
  static bool get isProd    => _env == _Env.prod;
  static bool get logEnabled => !isProd;

  // ── Timeouts ─────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout    = Duration(seconds: 30);
}

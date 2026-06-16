import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Services extends GetxService {
  late SharedPreferences _prefs;

  // ── Storage keys ─────────────────────────────────────────
  static const _kToken      = 'token';
  static const _kTheme      = 'theme_mode';
  static const _kLang       = 'lang';
  static const _kOnboard    = 'onboarding_done';
  static const _kLangChosen = 'lang_chosen';
  static const _kCompany    = 'company_name';
  static const _kUserId     = 'user_id';
  static const _kUserEmail  = 'user_email';
  static const _kUserRole   = 'user_role';
  static const _kTokenExp   = 'token_exp';     // unix timestamp

  // ── Init ─────────────────────────────────────────────────
  Future<Services> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ── Auth getters ─────────────────────────────────────────
  String get token       => _prefs.getString(_kToken)     ?? '';
  String get companyName => _prefs.getString(_kCompany)   ?? '';
  int    get userId      => _prefs.getInt(_kUserId)       ?? 0;
  String get userEmail   => _prefs.getString(_kUserEmail) ?? '';
  String get userRole    => _prefs.getString(_kUserRole)  ?? 'visitor';
  bool   get isLoggedIn  => token.isNotEmpty;

  /// true if token exists and not expired
  bool get isSessionValid {
    if (token.isEmpty) return false;
    final exp = _prefs.getInt(_kTokenExp) ?? 0;
    if (exp == 0) return true; // no expiry stored → assume valid
    return DateTime.now().millisecondsSinceEpoch < exp;
  }

  // ── Preferences getters ───────────────────────────────────
  bool   get isDarkMode  => _prefs.getBool(_kTheme)      ?? true;
  String get lang        => _prefs.getString(_kLang)     ?? 'ar';
  bool   get onboardDone => _prefs.getBool(_kOnboard)    ?? false;
  bool   get langChosen  => _prefs.getBool(_kLangChosen) ?? false;

  // ── Auth setters ─────────────────────────────────────────
  Future<void> saveToken(String t) => _prefs.setString(_kToken, t);

  Future<void> saveUserData({
    required String token,
    required String company,
    String email  = '',
    int    userId = 0,
    String role   = 'visitor',
    int    tokenExpiresInSeconds = 0,
  }) async {
    await _prefs.setString(_kToken,     token);
    await _prefs.setString(_kCompany,   company);
    await _prefs.setString(_kUserEmail, email);
    await _prefs.setInt(_kUserId,       userId);
    await _prefs.setString(_kUserRole,  role);
    if (tokenExpiresInSeconds > 0) {
      final exp = DateTime.now()
          .add(Duration(seconds: tokenExpiresInSeconds))
          .millisecondsSinceEpoch;
      await _prefs.setInt(_kTokenExp, exp);
    }
  }

  // kept for backward-compat with old controllers
  Future<void> saveCompany(String name) => _prefs.setString(_kCompany, name);

  // ── Preferences setters ───────────────────────────────────
  Future<void> saveTheme(bool isDark)  => _prefs.setBool(_kTheme, isDark);
  Future<void> saveLang(String l)      => _prefs.setString(_kLang, l);
  Future<void> setOnboardDone()        => _prefs.setBool(_kOnboard, true);
  Future<void> setLangChosen()         => _prefs.setBool(_kLangChosen, true);

  // ── Session clear (logout) ────────────────────────────────
  Future<void> clearSession() async {
    await Future.wait([
      _prefs.remove(_kToken),
      _prefs.remove(_kCompany),
      _prefs.remove(_kUserId),
      _prefs.remove(_kUserEmail),
      _prefs.remove(_kUserRole),
      _prefs.remove(_kTokenExp),
    ]);
  }
}

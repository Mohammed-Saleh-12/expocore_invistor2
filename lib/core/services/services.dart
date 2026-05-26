import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Services extends GetxService {
  late SharedPreferences _prefs;

  static const String _tokenKey     = 'token';
  static const String _themeKey     = 'theme_mode';
  static const String _langKey      = 'lang';
  static const String _onboardKey   = 'onboarding_done';
  static const String _companyKey   = 'company_name';

  Future<Services> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  String get token       => _prefs.getString(_tokenKey) ?? '';
  bool   get isDarkMode  => _prefs.getBool(_themeKey) ?? true;
  String get lang        => _prefs.getString(_langKey) ?? 'ar';
  bool   get onboardDone => _prefs.getBool(_onboardKey) ?? false;
  String get companyName => _prefs.getString(_companyKey) ?? 'شركتي';

  Future<void> saveToken(String token)  => _prefs.setString(_tokenKey, token);
  Future<void> saveTheme(bool isDark)   => _prefs.setBool(_themeKey, isDark);
  Future<void> saveLang(String lang)    => _prefs.setString(_langKey, lang);
  Future<void> setOnboardDone()         => _prefs.setBool(_onboardKey, true);
  Future<void> saveCompany(String name) => _prefs.setString(_companyKey, name);

  Future<void> clearSession() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_companyKey);
  }

  bool get isLoggedIn => token.isNotEmpty;
}

import 'package:shared_preferences/shared_preferences.dart';

class AppSecurityService {
  static const String appLockEnabledKey = 'appLockEnabled';
  static const String appLockPinKey = 'appLockPin';

  static Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(appLockEnabledKey) ?? false;
  }

  static Future<void> enableAppLock(String pin) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(appLockEnabledKey, true);
    await prefs.setString(appLockPinKey, pin);
  }

  static Future<void> disableAppLock() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(appLockEnabledKey, false);
    await prefs.remove(appLockPinKey);
  }

  static Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(appLockPinKey) == pin;
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class HighScore {
  static const _key = 'highest_score';

  static Future<int> get() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_key) ?? 0;
  }

  static Future<void> setIfHigher(int value) async {
    final sp = await SharedPreferences.getInstance();
    final cur = sp.getInt(_key) ?? 0;
    if (value > cur) await sp.setInt(_key, value);
  }
}

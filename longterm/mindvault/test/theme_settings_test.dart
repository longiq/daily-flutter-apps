import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindvault/services/theme_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeSettings', () {
    test('mặc định là ThemeMode.system khi chưa lưu gì', () async {
      final settings = ThemeSettings();
      await settings.load();
      expect(settings.mode, ThemeMode.system);
    });

    test('setMode lưu lại và load() đọc đúng giá trị đã lưu', () async {
      final settings = ThemeSettings();
      await settings.load();
      await settings.setMode(ThemeMode.dark);
      expect(settings.mode, ThemeMode.dark);

      final reloaded = ThemeSettings();
      await reloaded.load();
      expect(reloaded.mode, ThemeMode.dark);
    });

    test('setMode(light) rồi setMode(system) đọc lại đúng thứ tự', () async {
      final settings = ThemeSettings();
      await settings.load();
      await settings.setMode(ThemeMode.light);
      expect(settings.mode, ThemeMode.light);
      await settings.setMode(ThemeMode.system);
      expect(settings.mode, ThemeMode.system);

      final reloaded = ThemeSettings();
      await reloaded.load();
      expect(reloaded.mode, ThemeMode.system);
    });

    test('notifyListeners được gọi khi đổi mode', () async {
      final settings = ThemeSettings();
      await settings.load();
      var notified = 0;
      settings.addListener(() => notified++);
      await settings.setMode(ThemeMode.dark);
      expect(notified, 1);
      // đổi về cùng giá trị thì không notify lại
      await settings.setMode(ThemeMode.dark);
      expect(notified, 1);
    });
  });
}

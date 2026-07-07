import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindvault/services/ai_settings.dart';
import 'package:mindvault/services/ollama_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OllamaService', () {
    test('isAvailable false khi client không kết nối được (throw)', () async {
      final client = MockClient((request) async => throw Exception('offline'));
      final settings = AiSettings();
      final service = OllamaService(settings: settings, client: client);
      expect(await service.isAvailable(), isFalse);
    });

    test('isAvailable true khi server trả 200', () async {
      final client = MockClient((request) async => http.Response('{}', 200));
      final settings = AiSettings();
      final service = OllamaService(settings: settings, client: client);
      expect(await service.isAvailable(), isTrue);
    });

    test('generate trả fromOllama=false khi AI bị tắt trong cài đặt',
        () async {
      final client = MockClient((request) async => http.Response('{}', 200));
      final settings = AiSettings();
      await settings.update(enabled: false);
      final service = OllamaService(settings: settings, client: client);
      final result = await service.generate('xin chào');
      expect(result.fromOllama, isFalse);
      expect(result.error, isNotNull);
    });

    test('generate parse đúng field "response" từ JSON của Ollama', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/generate');
        return http.Response(jsonEncode({'response': 'Xin chào bạn'}), 200);
      });
      final settings = AiSettings();
      final service = OllamaService(settings: settings, client: client);
      final result = await service.generate('hi');
      expect(result.fromOllama, isTrue);
      expect(result.text, 'Xin chào bạn');
    });

    test('generate trả lỗi rõ ràng khi HTTP status != 200', () async {
      final client = MockClient((request) async => http.Response('err', 500));
      final settings = AiSettings();
      final service = OllamaService(settings: settings, client: client);
      final result = await service.generate('hi');
      expect(result.fromOllama, isFalse);
      expect(result.error, contains('500'));
    });
  });
}

import 'package:adaptive_video_player/adaptive_video_player.dart';
import 'package:flutter_test/flutter_test.dart';

abstract class MockService {
  String get name;
}

class MockServiceImpl implements MockService {
  @override
  final String name;
  MockServiceImpl(this.name);
}

void main() {
  group('ServiceLocator (Dependency Injection Container)', () {
    late ServiceLocator locator;

    setUp(() {
      locator = ServiceLocator();
      locator.reset();
    });

    test('registers and resolves eager singleton', () {
      final service = MockServiceImpl('singleton');
      locator.registerSingleton<MockService>(service);

      expect(locator.isRegistered<MockService>(), isTrue);
      expect(locator.get<MockService>().name, 'singleton');
      expect(identical(locator.get<MockService>(), service), isTrue);
    });

    test('registers and resolves lazy singleton', () {
      int createCount = 0;
      locator.registerLazySingleton<MockService>(() {
        createCount++;
        return MockServiceImpl('lazy_$createCount');
      });

      expect(createCount, 0);
      final s1 = locator.get<MockService>();
      expect(createCount, 1);
      final s2 = locator.get<MockService>();
      expect(createCount, 1);
      expect(identical(s1, s2), isTrue);
    });

    test('registers and resolves factory (new instance every time)', () {
      int count = 0;
      locator.registerFactory<MockService>(() {
        count++;
        return MockServiceImpl('instance_$count');
      });

      final s1 = locator.get<MockService>();
      final s2 = locator.get<MockService>();
      expect(s1.name, 'instance_1');
      expect(s2.name, 'instance_2');
      expect(identical(s1, s2), isFalse);
    });

    test('throws StateError when resolving unregistered service', () {
      expect(() => locator.get<String>(), throwsStateError);
    });

    test('unregisters service successfully', () {
      locator.registerSingleton<String>('hello');
      expect(locator.isRegistered<String>(), isTrue);

      locator.unregister<String>();
      expect(locator.isRegistered<String>(), isFalse);
      expect(() => locator.get<String>(), throwsStateError);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await ScreenProtectionService.resetAll();
  });

  tearDown(() async {
    await ScreenProtectionService.resetAll();
  });

  group('ScreenProtectionService Tests', () {
    test('isProtected defaults to false', () {
      expect(ScreenProtectionService.isProtected, false);
      expect(ScreenProtectionService.isProtectedNotifier.value, false);
    });

    test('enable and disable toggle isProtected correctly', () async {
      final owner = Object();
      await ScreenProtectionService.registerOwner(owner);
      expect(ScreenProtectionService.isProtected, true);
      expect(ScreenProtectionService.isProtectedNotifier.value, true);

      await ScreenProtectionService.unregisterOwner(owner);
      expect(ScreenProtectionService.isProtected, false);
      expect(ScreenProtectionService.isProtectedNotifier.value, false);
    });

    test('multi-owner reference counting keeps protection active until all unregister', () async {
      final owner1 = Object();
      final owner2 = Object();

      await ScreenProtectionService.registerOwner(owner1);
      await ScreenProtectionService.registerOwner(owner2);
      expect(ScreenProtectionService.isProtected, true);

      // Unregistering owner1 still leaves owner2 active
      await ScreenProtectionService.unregisterOwner(owner1);
      expect(ScreenProtectionService.isProtected, true);

      // Unregistering owner2 turns off protection
      await ScreenProtectionService.unregisterOwner(owner2);
      expect(ScreenProtectionService.isProtected, false);
    });

    test('setEnabledFor toggles state per owner', () async {
      final owner = Object();

      await ScreenProtectionService.setEnabledFor(owner, true);
      expect(ScreenProtectionService.isProtected, true);

      await ScreenProtectionService.setEnabledFor(owner, false);
      expect(ScreenProtectionService.isProtected, false);
    });

    test('resetAll unregisters all owners immediately', () async {
      final owner1 = Object();
      final owner2 = Object();

      await ScreenProtectionService.registerOwner(owner1);
      await ScreenProtectionService.registerOwner(owner2);
      expect(ScreenProtectionService.isProtected, true);

      await ScreenProtectionService.resetAll();
      expect(ScreenProtectionService.isProtected, false);
    });

    test('convenience methods enable, disable, and setEnabled work as expected', () async {
      await ScreenProtectionService.enable();
      expect(ScreenProtectionService.isProtected, true);

      await ScreenProtectionService.disable();
      expect(ScreenProtectionService.isProtected, false);

      await ScreenProtectionService.setEnabled(true);
      expect(ScreenProtectionService.isProtected, true);

      await ScreenProtectionService.setEnabled(false);
      expect(ScreenProtectionService.isProtected, false);
    });
  });
}

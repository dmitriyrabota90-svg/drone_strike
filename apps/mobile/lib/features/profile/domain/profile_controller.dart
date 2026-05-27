import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/auth_controller.dart';

final profileControllerProvider = Provider<ProfileController>((ref) {
  return ProfileController(ref);
});

class ProfileController {
  const ProfileController(this._ref);

  final Ref _ref;

  Future<void> reloadMe() {
    return _ref.read(authControllerProvider.notifier).reloadMe();
  }

  Future<void> updateDisplayName(String displayName) {
    return _ref
        .read(authControllerProvider.notifier)
        .updateDisplayName(displayName);
  }

  Future<void> requestEmailVerification() {
    return _ref
        .read(authControllerProvider.notifier)
        .requestEmailVerification();
  }
}

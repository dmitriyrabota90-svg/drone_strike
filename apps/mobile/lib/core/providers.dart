import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/auth_api.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/legal/data/legal_api.dart';
import '../features/legal/data/legal_repository.dart';
import '../features/profile/data/profile_api.dart';
import '../features/profile/data/profile_repository.dart';
import 'network/api_client.dart';
import 'storage/secure_token_storage.dart';

final secureTokenStorageProvider = Provider<SecureTokenStorage>((ref) {
  return const SecureTokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenStorage: ref.watch(secureTokenStorageProvider));
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authApi: ref.watch(authApiProvider),
    tokenStorage: ref.watch(secureTokenStorageProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});

final profileApiProvider = Provider<ProfileApi>((ref) {
  return ProfileApi(ref.watch(apiClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(profileApiProvider));
});

final legalApiProvider = Provider<LegalApi>((ref) {
  return LegalApi(ref.watch(apiClientProvider));
});

final legalRepositoryProvider = Provider<LegalRepository>((ref) {
  return LegalRepository(ref.watch(legalApiProvider));
});

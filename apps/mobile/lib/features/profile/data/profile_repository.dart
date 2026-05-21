import 'profile_api.dart';
import 'profile_dto.dart';

class ProfileRepository {
  const ProfileRepository(this._profileApi);

  final ProfileApi _profileApi;

  Future<MeDto> getMe() {
    return _profileApi.getMe();
  }

  Future<MeDto> updateDisplayName(String displayName) {
    return _profileApi.updateDisplayName(displayName);
  }
}

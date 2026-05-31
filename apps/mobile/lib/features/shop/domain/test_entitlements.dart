class TestEntitlements {
  const TestEntitlements._();

  static const _shopUnlockEmail = 'anpilovdmitriy@yandex.ru';

  // Temporary alpha-only entitlement for internal QA. Remove this helper when
  // real shop ownership/RuStore Billing is connected.
  static bool unlocksShopForEmail(String? email) {
    return email?.trim().toLowerCase() == _shopUnlockEmail;
  }
}

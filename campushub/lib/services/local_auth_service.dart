class LocalUserAccount {
  const LocalUserAccount({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;
}

class LocalAuthService {
  LocalAuthService._();

  static final List<LocalUserAccount> _accounts = <LocalUserAccount>[];

  static bool usernameExists(String username) {
    final normalized = username.trim().toLowerCase();
    return _accounts.any(
      (account) => account.username.toLowerCase() == normalized,
    );
  }

  static bool emailExists(String email) {
    final normalized = email.trim().toLowerCase();
    return _accounts.any(
      (account) => account.email.toLowerCase() == normalized,
    );
  }

  static void createAccount(LocalUserAccount account) {
    _accounts.add(account);
  }

  static LocalUserAccount? login({
    required String usernameOrEmail,
    required String password,
  }) {
    final normalizedIdentifier = usernameOrEmail.trim().toLowerCase();

    for (final account in _accounts) {
      final matchesIdentifier =
          account.username.toLowerCase() == normalizedIdentifier ||
          account.email.toLowerCase() == normalizedIdentifier;
      final matchesPassword = account.password == password;

      if (matchesIdentifier && matchesPassword) {
        return account;
      }
    }

    return null;
  }
}

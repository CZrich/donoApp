import 'package:bcrypt/bcrypt.dart';

class PasswordHasher {
  const PasswordHasher({this.cost = 12});

  final int cost;

  String hash(String password) =>
      BCrypt.hashpw(password, BCrypt.gensalt(logRounds: cost));

  bool verify(String password, String hash) => BCrypt.checkpw(password, hash);
}

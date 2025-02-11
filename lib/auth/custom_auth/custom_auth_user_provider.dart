import 'package:rxdart/rxdart.dart';

import '../../backend/schema/structs/user_struct.dart';
import '/backend/schema/structs/index.dart';
import 'custom_auth_manager.dart';

class GrazeAuthUser {
  GrazeAuthUser({
    required this.loggedIn,
    this.uid,
    this.userData,
  });

  bool loggedIn;
  String? uid;
  UserStruct? userData;
}

/// Generates a stream of the authenticated user.
BehaviorSubject<GrazeAuthUser> grazeAuthUserSubject =
    BehaviorSubject.seeded(GrazeAuthUser(loggedIn: false));
Stream<GrazeAuthUser> grazeAuthUserStream() =>
    grazeAuthUserSubject.asBroadcastStream().map((user) => currentUser = user);



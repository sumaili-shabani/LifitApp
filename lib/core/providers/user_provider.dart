import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' show min;

class UserState {
  final String name;
  final String email;
  final String? photoUrl;

  const UserState({
    required this.name,
    required this.email,
    this.photoUrl,
  });

  String get initials {
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
  }

  UserState copyWith({
    String? name,
    String? email,
    String? photoUrl,
  }) {
    return UserState(
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier()
      : super(const UserState(
          name: 'John Doe',
          email: 'john.doe@example.com',
        ));

  void updateUser({
    String? name,
    String? email,
    String? photoUrl,
  }) {
    state = state.copyWith(
      name: name,
      email: email,
      photoUrl: photoUrl,
    );
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

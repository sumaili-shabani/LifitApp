part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  const AuthLogin({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthLogout extends AuthEvent {
  const AuthLogout();
  @override
  List<Object?> get props => [];
}

class AuthRefresh extends AuthEvent {
  const AuthRefresh();
  @override
  List<Object?> get props => [];
}

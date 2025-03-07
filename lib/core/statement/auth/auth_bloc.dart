import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../network/api_client.dart';
import '../../models/auth.dart';
import '../../services/storage_service.dart';
import '../../di/service_locator.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final apiClient = ApiClient();
  final _storage = StorageService();

  AuthBloc() : super(AuthInitial()) {
    on<AuthLogin>(_login);
    on<AuthLogout>(_logout);
    // Check stored data on initialization
    _checkStoredData();
  }

  void _checkStoredData() {
    final storedUser = _storage.getUser();
    if (storedUser != null && storedUser.data.isNotEmpty) {
      // ignore: invalid_use_of_visible_for_testing_member
      emit(AuthSuccess(user: storedUser.data.first));
    }
  }

  Future<void> _login(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await apiClient.get('login_mobile',
          queryParameters: {'email': event.email, 'password': event.password});

      if (response.data != null) {
        if (response.data == false) {
          emit(const AuthFailure('Email ou mot de passe incorrect'));
          return;
        }

        final loginModel = ModelLogin.fromJson(response.data);
        if (loginModel.data.isNotEmpty) {
          final userData = loginModel.data.first;
          await _storage.saveUserSession(loginModel);
          emit(AuthSuccess(user: userData));
        } else {
          emit(const AuthFailure('Aucune donnée utilisateur trouvée'));
        }
      } else {
        emit(const AuthFailure('Email ou mot de passe incorrect'));
      }
    } catch (e) {
      emit(AuthFailure('Erreur de connexion: ${e.toString()}'));
    }
  }

  Future<void> _logout(AuthLogout event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _storage.clearSession();
      emit(AuthInitial());
    } on Exception catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}

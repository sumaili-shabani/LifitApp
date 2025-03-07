import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifti_app/core/models/account.dart';
import '../../network/api_client.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final apiClient = ApiClient();

  AccountBloc() : super(AccountInitial()) {
    on<AccountCreate>(_createAccount);
    on<AccountUpdate>(_updateAccount);
    on<AccountDelete>(_deleteAccount);
  }

  Future<void> _createAccount(
      AccountCreate event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final response =
          await apiClient.post('insert_user_mobile', data: event.user.toJson());
      if (response.data != null) {
        emit(AccountLoaded(user: response.data));
      } else {
        emit(AccountError(message: 'Erreur de connexion'));
      }
    } on Exception catch (e) {
      emit(AccountError(message: e.toString()));
    }
  }

  Future<void> _updateAccount(
      AccountUpdate event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {} on Exception catch (e) {
      emit(AccountError(message: e.toString()));
    }
  }

  Future<void> _deleteAccount(
      AccountDelete event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {} on Exception catch (e) {
      emit(AccountError(message: e.toString()));
    }
  }
}

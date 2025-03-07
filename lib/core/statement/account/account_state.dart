part of 'account_bloc.dart';

abstract class AccountState extends Equatable {
  @override
  List<Object> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoaded extends AccountState {
  final ModelAccount user;

  AccountLoaded({required this.user});
}

class AccountError extends AccountState {
  final String message;

  AccountError({required this.message});
}

class AccountLoading extends AccountState {}

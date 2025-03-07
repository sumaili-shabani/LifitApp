part of 'account_bloc.dart';

abstract class AccountEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AccountCreate extends AccountEvent {
  @override
  List<Object> get props => [];
  final ModelAccount user;
  AccountCreate({required this.user});
}

class AccountUpdate extends AccountEvent {
  @override
  List<Object> get props => [];
  final ModelAccount user;
  AccountUpdate({required this.user});
}

class AccountDelete extends AccountEvent {
  @override
  List<Object> get props => [];
  final String id;
  AccountDelete({required this.id});
}

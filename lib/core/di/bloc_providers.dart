import 'package:flutter_bloc/flutter_bloc.dart';
import '../statement/account/account_bloc.dart';
import '../statement/auth/auth_bloc.dart';

class BlocProviders {
  static final List<BlocProvider> providers = [
    BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(),
    ),
    BlocProvider<AccountBloc>(
      create: (context) => AccountBloc(),
    ),
  ];
}

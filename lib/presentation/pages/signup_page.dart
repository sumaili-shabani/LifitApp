import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/AnimatedPageRoute.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/presentation/pages/login_page.dart';
import '../../core/statement/account/account_bloc.dart';

class SignupPage extends ConsumerStatefulWidget {
  final String? completePhone;
  const SignupPage({super.key, this.completePhone});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      String mail = CallApi.generateEmail(_nameController.text);
     
      Map<String, dynamic> svData = {
        'id': '',
        'name': _nameController.text,
        'email':_emailController.text.isEmpty? mail: _emailController.text,
        'address': '',
        'password': _passwordController.text,
        'sexe': '',
        'telephone': _phoneController.text,
        'adresse': '',
      };
      // print('svData: $svData');

      final response = await CallApi.postData("register", svData);
      final data = response;
      print(data);

      if (data['wrong'] == true) {
        showSnackBar(context, data['message'], "danger");
      } else {
        showSnackBar(context, data['message'], "success");
        // redirection vers la page de connexion
        Navigator.of(context).pop(); // Retour à la page précédente

         Navigator.of(context).push(
          AnimatedPageRoute(
            page: LoginPage(),
          ),
        );

      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.completePhone! != '') {
      setState(() {
        _phoneController.text = widget.completePhone!.toString();
      });
      
    } else {
      
    }
  }

  @override
  void dispose() {
    // _nameController.dispose();
    // _emailController.dispose();
    // _phoneController.dispose();
    // _passwordController.dispose();
    // _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(l10n.signUp), centerTitle: true,
        // backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is AccountError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AccountLoaded) {
            Navigator.of(context).pop(); // Retour à la page précédente
          }
        },
        child: Stack(
          children: [
            // Background gradient animation
            // AnimatedContainer(
            //   duration: const Duration(milliseconds: 500),
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.topCenter,
            //       end: Alignment.bottomCenter,
            //       colors: [
            //         theme.colorScheme.primary.withOpacity(0.1),
            //         theme.colorScheme.surface,
            //       ],
            //       stops: [0.0, 0.8],
            //     ),
            //   ),
            // ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Text(
                      l10n.createAccount,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
            
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.fullName,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.nameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
            
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: l10n.email,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      
                    ),
                    const SizedBox(height: 16),
            
                    // Phone field
                    // TextFormField(
                    //   controller: _phoneController,
                    //   decoration: InputDecoration(
                    //     labelText: l10n.phoneNumber,
                    //     prefixIcon: const Icon(Icons.phone_outlined),
                    //   ),
                    //   keyboardType: TextInputType.phone,
                    //   textInputAction: TextInputAction.next,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return l10n.phoneRequired;
                    //     }
                    //     return null;
                    //   },
                    // ),
                    // const SizedBox(height: 16),
            
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.passwordRequired;
                        }
                        if (value.length < 4) {
                          return l10n.passwordTooShort;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
            
                    // Confirm password field
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: l10n.confirmPassword,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.confirmPasswordRequired;
                        }
                        if (value != _passwordController.text) {
                          return l10n.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
            
                    // Terms and conditions checkbox
                    CheckboxListTile(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                      title: Text(l10n.acceptTerms),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 24),
            
                    // Sign up button
                    ElevatedButton(
                      onPressed: _acceptTerms ? _handleSignup : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: BlocBuilder<AccountBloc, AccountState>(
                        builder: (context, state) {
                          if (state is AccountLoading) {
                            return const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            );
                          }
                          return Text(l10n.signUp);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
            
                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.alreadyHaveAccount),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(l10n.login),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

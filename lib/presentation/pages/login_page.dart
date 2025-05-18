import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/AnimatedPageRoute.dart';
import 'package:lifti_app/Components/ButtonComponent.dart';
import 'package:lifti_app/Components/TextFildComponent.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/View/Pages/AmbassadeurApp.dart';
import 'package:lifti_app/View/Pages/ChauffeurApp.dart';
import 'package:lifti_app/View/Pages/PassagerApp.dart';
import 'package:lifti_app/presentation/pages/Otp/PhoneNumberPage.dart';

import 'package:lifti_app/presentation/pages/forgot_password_page.dart';
import 'package:lifti_app/presentation/pages/signup_page.dart';
import 'package:lifti_app/presentation/widgets/animated_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //Our controllers
  //Controller is used to take the value from user and pass it to database
  final usrName = TextEditingController();
  final password = TextEditingController();

  bool isChecked = false;
  bool isLoginTrue = false;
  bool _obscurePassword = true;

  //Login Method
  //We will take the value of text fields using controllers in order to verify whether details are correct or not

  showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: ConfigurationApp.dangerColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  //script pour le login

  final formKey = GlobalKey<FormState>();
  signIn() async {
    if (formKey.currentState!.validate()) {
      try {
        final response = await CallApi.postData("login", {
          "email": usrName.text,
          "password": password.text,
        });
        final data = response;

        print(data['wrong']);

        if (data['wrong'] == true) {
          showSnackBar(context, data['message'], "danger");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Bienvenu ${data['user']['name']}")),
          );

          // redirection vers son tableau de bord
          SharedPreferences localStorage =
              await SharedPreferences.getInstance();
          localStorage.setInt('idConnected', data['user']['id']);
          localStorage.setString('nameConnected', data['user']['name']);
          localStorage.setInt('idRoleConnected', data['user']['id_role']);
          localStorage.setString('emailConnected', data['user']['email']);
          localStorage.setString('avatarConnected', data['user']['avatar']);
          //activation de la session
          localStorage.setString('token', data['token']);

          String jsonString = jsonEncode(
            data['user'],
          ); // Convertir le Map en String
          await localStorage.setString('userData', jsonString);

          //test de role
          if (data['user']['id_role'] == 3) {
            Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        const ChauffeurApp(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(
                  milliseconds: 500,
                ), // Durée de l'animation
              ),
              (route) => false, // Supprime toutes les pages précédentes
            );
          } else if (data['user']['id_role'] == 4) {
            Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        const PassagerApp(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(
                  milliseconds: 500,
                ), // Durée de l'animation
              ),
              (route) => false, // Supprime toutes les pages précédentes
            );
          } else if (data['user']['id_role'] == 2) {
            Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        const AmbassadeurApp(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(
                  milliseconds: 500,
                ), // Durée de l'animation
              ),
              (route) => false, // Supprime toutes les pages précédentes
            );
          } else {}
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
        // print("Oups une erreur!!!!! message:" + e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    Size size = MediaQuery.of(context).size;
    bool _rememberMe = false;
    return Scaffold(
      // backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      // extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background gradient animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.surface,
                ],
                stops: [0.0, 0.8],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                child: Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("assets/images/logoApp.png", width: 210),

                              Padding(
                                padding: EdgeInsets.all(5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "🚦${l10n.login_ui_titre} 🚖",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          TextFildComponent(
                            labeltext: "${l10n.login_ui_email}",
                            hint: "${l10n.login_ui_email1}",
                            icon: Icons.email,
                            controller: usrName,
                            validatorInput: true,
                          ),

                          const SizedBox(height: 10),
                          // TextFildComponent(
                          //   labeltext: "Mot de passe",
                          //   hint: "Entre votre mot de passe",
                          //   icon: Icons.lock,
                          //   controller: password,
                          //   validatorInput: true,
                          // ),

                          // Password field
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            margin: const EdgeInsets.symmetric(vertical: 1),
                            width: size.width * .9,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: TextFormField(
                                controller: password,

                                decoration: InputDecoration(
                                  labelText: "${l10n.login_ui_password}",
                                  hintText: "${l10n.login_ui_password1}",

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
                                    return "${l10n.login_ui_text_error}";
                                  }
                                  if (value.length < 4) {
                                    return "${l10n.login_ui_text_error1}";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? true;
                                      });
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Text(
                                    "${l10n.login_ui_remember}",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                              AnimatedButton(
                                onPressed:
                                    () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (_) => const ForgotPasswordPage(),
                                      ),
                                    ),
                                backgroundColor: Colors.transparent,
                                foregroundColor: theme.colorScheme.primary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  "${l10n.login_ui_forgot_password}",
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          ButtonComponent(
                            icon: Icons.login,
                            label: "${l10n.login_ui_login}",
                            press: () {
                              signIn();
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${l10n.login_ui_dont_have_an_count}",
                                style: TextStyle(color: Colors.grey),
                              ),
                              TextButton(
                                onPressed: () {
                                  //
                                  // Navigator.of(
                                  //   context,
                                  // ).push(AnimatedPageRoute(page: SignupPage()));

                                  Navigator.of(
                                    context,
                                  ).push(AnimatedPageRoute(page: PhoneNumberPage()));

                                  
                                },
                                child: Text("${l10n.login_ui_signup}"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/ButtonComponent.dart';
import 'package:lifti_app/Components/TextFildComponent.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/View/Pages/ChauffeurApp.dart';

import 'package:lifti_app/presentation/pages/forgot_password_page.dart';
import 'package:lifti_app/presentation/pages/signup_page.dart';
import 'package:lifti_app/presentation/widgets/animated_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          localStorage.setString('nameConnected', data['user']['email']);
          localStorage.setInt('idRoleConnected', data['user']['id_role']);
          localStorage.setString('emailConnected', data['user']['email']);
          localStorage.setString('avatarConnected', data['user']['avatar']);
          //activation de la session
          localStorage.setString('token', data['token']);

          String jsonString = jsonEncode(
            data['user'],
          ); // Convertir le Map en String
          await localStorage.setString('userData', jsonString);

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ChauffeurApp()),
            (route) => false,
          );
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
    bool _rememberMe = false;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
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
                        Image.asset("assets/images/logo.png", width: 210),

                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "🚦Plus qu’un login… un trajet rapide et sécurisé! Prêt pour le départ ? Connectez-vous ! 🚖",
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
                      labeltext: "Email et N° Téléphone",
                      hint: "Entrer Email  ou N° Téléphone",
                      icon: Icons.email,
                      controller: usrName,
                      validatorInput: true,
                    ),

                    const SizedBox(height: 10),
                    TextFildComponent(
                      labeltext: "Mot de passe",
                      hint: "Entre votre mot de passe",
                      icon: Icons.lock,
                      controller: password,
                      validatorInput: true,
                    ),

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
                                  _rememberMe = value ?? false;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Text(
                              "Souviens-toi de moi",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AnimatedButton(
                          onPressed:
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordPage(),
                                ),
                              ),
                          backgroundColor: Colors.transparent,
                          foregroundColor: theme.colorScheme.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "Mot de passe oublié?",
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
                      label: "SE CONNECTER",
                      press: () {
                        signIn();
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Vous n'avez pas de compte ?",
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            //
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignupPage(),
                              ),
                            );
                          },
                          child: const Text("S'inscrire"),
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
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/presentation/pages/Otp/OTPVerificationPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final phoneController = TextEditingController();
  String completePhone = '';
  String generatedOTP = '';
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  getnumeroNumber() async {
    if (formKey.currentState!.validate()) {
      if (completePhone != "") {
        try {
          setState(() {
            isLoading = true;
          });
          Map<String, dynamic> svData = {"telephone": completePhone.toString()};
          final response = await CallApi.postData("check_phone_number", svData);
          final data = response;
          // print("svData: $svData");
          // print("wrong:${data['wrong']}");
          // print("wrong:${data['message']}");

          if (data['wrong'] == true) {
            setState(() {
              isLoading = false;
            });
            showSnackBar(context, data['message'], "danger");
          } else {
            setState(() {
              isLoading = false;
            });

            sendOTPViaWhatsApp();
          }
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
          // print("Oups une erreur!!!!! message:" + e.toString());

          setState(() {
            isLoading = false;
          });
        }
      } else {
        showSnackBar(
          context,
          "Veillez entrer le numéro de téléphone",
          "danger",
        );
      }
    }
  }

  void sendOTPViaWhatsApp() async {
    generatedOTP = (Random().nextInt(900000) + 100000).toString();
    final message = "Votre code OTP est : $generatedOTP";
    final waUrl =
        "https://wa.me/${completePhone.replaceAll('+', '')}?text=${Uri.encodeComponent(message)}";

    if (await canLaunch(waUrl)) {
      await launch(waUrl);
      Navigator.of(context).pop(); // Retour à la page précédente
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => OTPVerificationPage(
                expectedOTP: generatedOTP,
                completePhone: completePhone,
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Impossible d'ouvrir WhatsApp")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.signUpPhone),
        centerTitle: true,
        // backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/logoApp.png", width: 210),
                  Text(
                    "${l10n.otp_ui_titre} ",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${l10n.otp_ui_titre1}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "${l10n.otp_ui_nom}",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 5),
                  IntlPhoneField(
                    decoration: InputDecoration(
                      labelText: '${l10n.otp_ui_num_telephone}',
                      border: OutlineInputBorder(),
                    ),
                    initialCountryCode: 'CD',
                    controller: phoneController,
                    onChanged: (phone) {
                      completePhone = phone.completeNumber;
                    },
                    validator: (value) {
                      if (value == null) {
                        return l10n.nameRequired;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: isLoading ? null : Icon(Icons.send),
                    onPressed: isLoading ? null : getnumeroNumber,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    label:
                        isLoading
                            ? Center(child: CircularProgressIndicator())
                            : Text("${l10n.otp_ui_submit}"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

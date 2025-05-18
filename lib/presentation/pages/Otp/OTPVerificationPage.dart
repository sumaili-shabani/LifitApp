import 'package:flutter/material.dart';
import 'package:lifti_app/Components/AnimatedPageRoute.dart';
import 'package:lifti_app/presentation/pages/signup_page.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OTPVerificationPage extends StatefulWidget {
  final String expectedOTP;
  final String completePhone;
  const OTPVerificationPage({
    super.key,
    required this.expectedOTP,
    required this.completePhone,
  });

  @override
  OTPVerificationPageState createState() => OTPVerificationPageState();
}

class OTPVerificationPageState extends State<OTPVerificationPage> {
  String enteredOTP = '';

  void verifyOTP() {
    if (enteredOTP == widget.expectedOTP) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => SignupPage()),
      // );
      Navigator.of(context).pop(); // Retour à la page précédente
      Navigator.of(context).push(AnimatedPageRoute(page: SignupPage(completePhone: widget.completePhone,)));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Code incorrect")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${l10n.otp_ui_text_otp_sender} ",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            PinCodeTextField(
              appContext: context,
              length: 6,
              onChanged: (_) {},
              onCompleted: (value) => enteredOTP = value,
              keyboardType: TextInputType.number,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
                selectedFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                activeColor: Colors.indigo,
                selectedColor: Colors.orange,
                inactiveColor: Colors.grey,
                fieldOuterPadding: EdgeInsets.symmetric(horizontal: 4),
              ),
              enableActiveFill: true,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: verifyOTP,
              child: Text("${l10n.otp_ui_text_verify_opt}"),
            ),
          ],
        ),
      ),
    );
  }
}

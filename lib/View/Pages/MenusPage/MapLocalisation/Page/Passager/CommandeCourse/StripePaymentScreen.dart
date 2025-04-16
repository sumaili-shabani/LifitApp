import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';

class StripePaymentScreen extends StatefulWidget {
  final CourseInfoPassagerModel course;
  const StripePaymentScreen({super.key, required this.course});

  @override
  State<StripePaymentScreen> createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  Map<String, dynamic>? paymentIntent;

  Future<void> makePayment() async {
    try {
      // 1️⃣ Créer PaymentIntent depuis Laravel
      Map<String, dynamic> svData = {'amount': widget.course.montantCourse};
      final response = await CallApi.postData("create-payment-stripe", svData);

      final clientSecret = response['clientSecret'];
      print("Client Secret: $clientSecret");

      // 2️⃣ Afficher l'interface de paiement Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          applePay: null, // ✅ Correct
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: "US",
          ), // ✅ Correct
          style: ThemeMode.dark,
          merchantDisplayName: "Taxi Goma",
        ),
      );

      // 3️⃣ Afficher la boîte de dialogue de paiement
      await Stripe.instance.presentPaymentSheet();

      setState(() {
        paymentIntent = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Paiement réussi !")));
    } catch (e) {
      print("Erreur de paiement: $e");
      
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Échec du paiement")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height *
          0.55, // Augmenté à 55% pour plus de visibilité
      padding: EdgeInsets.all(16),
      child: Column(
      
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                makePayment();
              },
              child: Text("Ouvrir le paiement"),
            ),
          ),
        ],
      ),
    );
  }
}

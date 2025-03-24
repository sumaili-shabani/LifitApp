import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/StripePaymentScreen.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe; // ✅ Alias ajouté

class PaymentScreen extends StatefulWidget {
  final CourseInfoPassagerModel course;
  final Function(CourseInfoPassagerModel) onSubmitComment; // Callback function
  const PaymentScreen({
    super.key,
    required this.course,
    required this.onSubmitComment,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = "";
  String selectedMobileMoney = "";
  TextEditingController phoneController = TextEditingController();

  Widget _buildPaymentOption(
    String method,
    IconData icon,
    String description,
    CourseInfoPassagerModel course,
  ) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(method, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        onTap: () {
          setState(() {
            selectedPaymentMethod = method;
          });
          // Navigator.pop(context);
          if (method == "Mobile Money") {
            showMobileMoneyOptions(course);
          }
          if (method == "Banque (Stripe)") {
            // showStripePaiement(course);
            makePayment();
          }
        },
      ),
    );
  }

  void showMobileMoneyOptions(CourseInfoPassagerModel course) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height *
              0.55, // Augmenté à 60% pour plus de visibilité
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Sélectionnez un opérateur Mobile Money",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildMobileMoneyOption(
                "M-Pesa",
                "Vodacom",
                Icons.account_balance_wallet,
                Colors.white,
                "mpesa.png",
                course,
              ),
              _buildMobileMoneyOption(
                "Airtel Money",
                "Airtel",
                Icons.account_balance_wallet,
                Colors.white,
                "airtelmoney.png",
                course,
              ),
              _buildMobileMoneyOption(
                "Orange Money",
                "Orange",
                Icons.account_balance_wallet_rounded,
                Colors.white,
                "orangemoney.png",
                course,
              ),
            ],
          ),
        );
      },
    );
  }

  //course
  Map<String, dynamic>? paymentIntent;
  Future<void> makePayment() async {
    try {
      int? userId =
          await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
      String? sessionName = await CallApi.getNameConnected();
      
      // 1️⃣ Créer PaymentIntent depuis Laravel
      Map<String, dynamic> svData = {'amount': widget.course.montantCourse};
      final response = await CallApi.postData("create-payment-stripe", svData);

      final clientSecret = response['clientSecret'];
      print("Client Secret: $clientSecret");

      // 2️⃣ Afficher l'interface de paiement Stripe
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          applePay: null, // ✅ Correct
          googlePay: const stripe.PaymentSheetGooglePay(
            merchantCountryCode: "US",
          ), // ✅ Correct
          style: ThemeMode.dark,
          merchantDisplayName: "Taxi Goma",
        ),
      );

      // 3️⃣ Afficher la boîte de dialogue de paiement
      await stripe.Stripe.instance.presentPaymentSheet();

      

      //appel de la fonction d'insertion
      Map<String, dynamic> svData2 = {
        'refCourse': widget.course.id!,
        'montant_paie': widget.course.montantCourse!,
        'devise': widget.course.devise!,
        'date_paie': widget.course.dateCourse!,
        'libellepaie': "Paiement  ${widget.course.nomTypeCourse!}",
        'numeroBordereau': "Stripe account",
        'author': sessionName!.toString(),
        'refUser': userId!,
      };
      
      final inserted = await CallApi.insertData(
        endpoint: "passager_store_payement_banque",
        data: svData2,
        // token: token.toString(),
      );

      print("response: $inserted");

      String messagePayement = inserted['data'];
      print('message: $messagePayement');

      setState(() {
        paymentIntent = null;
      });

      showSnackBar(context, messagePayement, "success");
    } catch (e) {
      print("Erreur de paiement: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Échec du paiement")));
    }
  }

  // fin stripe

  Widget _buildMobileMoneyOption(
    String provider,
    String description,
    IconData icon,
    Color colorIcone,
    String imgFile,
    CourseInfoPassagerModel course,
  ) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorIcone,
          child: Image.asset('assets/images/$imgFile'),
        ),
        title: Text(provider, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        onTap: () {
          setState(() {
            selectedMobileMoney = provider;
          });
          Navigator.pop(context);
          showPhoneNumberInput(course);
        },
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "montant:",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              "${course.montantCourse} ${course.devise}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  void showPhoneNumberInput(CourseInfoPassagerModel course) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height *
              0.55, // Augmenté à 55% pour plus de visibilité
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Entrez votre numéro de téléphone",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Numéro Mobile Money",
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (phoneController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Veuillez entrer un numéro valide."),
                      ),
                    );
                  } else {
                    print(
                      "Paiement via $selectedMobileMoney avec numéro ${phoneController.text}",
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text("Confirmer"),
              ),
            ],
          ),
        );
      },
    );
  }

  void showStripePaiement(CourseInfoPassagerModel course) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StripePaymentScreen(course: course),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height:
          MediaQuery.of(context).size.height *
          0.55, // Augmenté à 55% pour plus de visibilité
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 5),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Choisissez un mode de paiement",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Mode de paiement sélectionné : $selectedPaymentMethod",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      _buildPaymentOption(
                        "Cash",
                        Icons.money,
                        "Payez directement au chauffeur",
                        widget.course,
                      ),
                      _buildPaymentOption(
                        "Banque (Stripe)",
                        Icons.credit_card,
                        "Paiement sécurisé via Stripe",
                        widget.course,
                      ),
                      _buildPaymentOption(
                        "Mobile Money",
                        Icons.phone_android,
                        "Paiement rapide via M-Pesa, Airtel ou Orange",
                        widget.course,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

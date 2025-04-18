import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/StripePaymentScreen.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe; // ✅ Alias ajouté

class WalletRechargePage extends StatefulWidget {
  final Function onSubmitComment;
  const WalletRechargePage({super.key, required this.onSubmitComment});

  @override
  State<WalletRechargePage> createState() => _WalletRechargePageState();
}

class _WalletRechargePageState extends State<WalletRechargePage> {
  String selectedPaymentMethod = "";
  String selectedMobileMoney = "";
  TextEditingController phoneController = TextEditingController();

  Widget _buildPaymentOption(
    String method,
    IconData icon,
    String description,
    String imgFile,
  ) {
    return insertedLoading
        ? Center(child: CircularProgressIndicator())
        : Card(
          elevation: 4,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Image.asset('assets/images/$imgFile', fit: BoxFit.cover),
            ),
            title: Text(method, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(description),
            onTap:
                insertedLoading
                    ? null
                    : () async {
                      setState(() {
                        selectedPaymentMethod = method;
                      });
                      // Navigator.pop(context);

                      if (method == "Cash") {
                        storePaymentBackendCash();
                      }
                      if (method == "Mobile Money") {
                        showMobileMoneyOptions();
                      }
                      if (method == "Banque (Stripe)") {
                        makePayment();
                      }
                      if (method == "Banque (Paypal)") {
                        print("paiement via Paypal");
                        startPaypalPayment(context);
                      }
                    },
          ),
        );
  }

  Future<void> startPaypalPayment(BuildContext context) async {
    try {
      double montant = double.parse("5") / 2850;
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => UsePaypal(
                sandboxMode:
                    CallApi
                        .sandboxModePaypal, // Changez en false pour production
                clientId:
                    CallApi.clientIDPaypal, // Remplacez avec votre ID PayPal
                secretKey:
                    CallApi.secretkeyPaypal, // Remplacez avec votre clé secrète
                returnURL: CallApi.baseUrl,
                cancelURL: CallApi.baseUrl,
                transactions: [
                  {
                    "amount": {
                      "total": montant.toStringAsFixed(0), // Montant total
                      "currency": "USD", // Devise (ex: EUR, USD)
                      "details": {
                        "subtotal": montant.toStringAsFixed(0),
                        "shipping": "0",
                        "shipping_discount": 0,
                      },
                    },
                    "description": "Paiement course de taxi swiftride",
                    "item_list": {
                      "items": [
                        {
                          "name": "widget.course.nomTypeCourse",
                          "quantity": 1,
                          "price": montant.toStringAsFixed(0),
                          "currency": "USD",
                        },
                      ],
                    },
                  },
                ],
                note: "Merci pour votre confiance !",
                onSuccess: (Map params) {
                  print("Paiement réussi : $params");
                  makePayment();
                },
                onCancel: (Map params) {
                  print("Paiement annulé : $params");
                },
                onError: (error) {
                  print("Erreur de paiement : $error");
                },
              ),
        ),
      );
      print("🔹 Résultat du paiement: $result");
    } catch (e) {
      print("⚠️ Erreur lors du paiement : $e");
    }
  }

  void showMobileMoneyOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height *
              0.65, // Augmenté à 65% pour plus de visibilité
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.flash_on, color: Colors.orange, size: 26),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recharge instantanée 💳",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Choisissez votre opérateur préféré pour recharger instantanément votre portefeuille.",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey[200]),
              SizedBox(height: 16),
              _buildMobileMoneyOption(
                "Vodacom (M-Pesa)",
                "Recharge rapide et sécurisée avec M-Pesa.",
                Icons.account_balance_wallet,
                Colors.white,
                "mpesa.png",

                2,
              ),
              _buildMobileMoneyOption(
                "Airtel(Airtel Money)",
                "Rechargez sans stress via Airtel",
                Icons.account_balance_wallet,
                Colors.white,
                "airtelmoney.png",

                3,
              ),
              _buildMobileMoneyOption(
                "Orange(Orange Money)",
                "Fiable et pratique, à tout moment",
                Icons.account_balance_wallet_rounded,
                Colors.white,
                "orangemoney.png",

                4,
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
      Map<String, dynamic> svData = {'amount': " 1000"};
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

      EasyLoading.show(
        status: 'Envoi en cours...',
        maskType: EasyLoadingMaskType.black,
      );
      setState(() {
        insertedLoading = true;
      });
      //appel de la fonction d'insertion
      Map<String, dynamic> svData2 = {
        'refCourse': "",
        'montant_paie': "widget.course.montantCourse!",
        'devise': "widget.course.devise!",
        'date_paie': " widget.course.dateCourse!",
        'libellepaie': "Paiement  ",
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

      EasyLoading.showSuccess(messagePayement);

      setState(() {
        insertedLoading = false;
      });

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
    int refBanque,
  ) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Image.asset('assets/images/$imgFile', fit: BoxFit.cover),
        ),
        title: Text(provider, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        onTap: () {
          setState(() {
            selectedMobileMoney = provider;
          });
          Navigator.pop(context);
          showPhoneNumberInput(refBanque);
        },
      ),
    );
  }

  void showPhoneNumberInp(int refBanque) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height *
              0.65, // Augmenté à 55% pour plus de visibilité
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
              insertedLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                    icon: Icon(Icons.payment),
                    onPressed:
                        insertedLoading
                            ? null
                            : () {
                              if (phoneController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Veuillez entrer un numéro valide.",
                                    ),
                                  ),
                                );
                              } else {
                                storePaymentBackendMobile(refBanque);
                                // print(
                                //   "Paiement via $selectedMobileMoney avec numéro ${phoneController.text}",
                                // );

                                Navigator.pop(context);
                              }
                            },
                    label: Text("Confirmer"),
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

  bool insertedLoading = false;

  storePaymentBackendMobile(int refBanque) async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    String? sessionName = await CallApi.getNameConnected();

    setState(() {
      insertedLoading = true;
    });
    EasyLoading.show(
      status: 'Envoi en cours...',
      maskType: EasyLoadingMaskType.black,
    );
    //appel de la fonction d'insertion
    Map<String, dynamic> svData2 = {
      'refCourse': "",
      'montant_paie': "widget.course.montantCourse!",
      'devise': "widget.course.devise!",
      'date_paie': " widget.course.dateCourse!",
      'libellepaie': "Paiement  ",
      'numeroBordereau': "Stripe account",
      'author': sessionName!.toString(),
      'refUser': userId!,
    };

    final inserted = await CallApi.insertData(
      endpoint: "passager_store_payement_mobile_money",
      data: svData2,
      // token: token.toString(),
    );
    // print("response: $inserted");
    String messagePayement = inserted['data'];
    print('message: $messagePayement');
    showSnackBar(context, messagePayement, 'success');

    EasyLoading.showSuccess(messagePayement);

    setState(() {
      insertedLoading = false;
    });
  }

  storePaymentBackendCash() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    String? sessionName = await CallApi.getNameConnected();

    setState(() {
      insertedLoading = true;
    });
    EasyLoading.show(
      status: 'Envoi en cours...',
      maskType: EasyLoadingMaskType.black,
    );
    //appel de la fonction d'insertion
    Map<String, dynamic> svData2 = {
      'refCourse': "",
      'montant_paie': "widget.course.montantCourse!",
      'devise': "widget.course.devise!",
      'date_paie': " widget.course.dateCourse!",
      'libellepaie': "Paiement  ",
      'numeroBordereau': "Stripe account",
      'author': sessionName!.toString(),
      'refUser': userId!,
    };

    final inserted = await CallApi.insertData(
      endpoint: "passager_store_payement_cash",
      data: svData2,
      // token: token.toString(),
    );
    // print("response: $inserted");
    String messagePayement = inserted['data'];
    print('message: $messagePayement');
    showSnackBar(context, messagePayement, 'success');

    setState(() {
      insertedLoading = false;
    });
    EasyLoading.showSuccess(messagePayement);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      height:
          MediaQuery.of(context).size.height *
          0.65, // Augmenté à 55% pour plus de visibilité
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
                  padding: EdgeInsets.all(4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "💳 Choisissez un mode de paiement",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Mode sélectionné : $selectedPaymentMethod",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildPaymentOption(
                        "Cash",
                        Icons.money,
                        "Recharger directement au chauffeur",

                        "Icon_cash.png",
                      ),
                      _buildPaymentOption(
                        "Banque (Stripe)",
                        Icons.credit_card,
                        "Recharge sécurisé via Stripe",

                        "stripe.png",
                      ),
                      _buildPaymentOption(
                        "Banque (Paypal)",
                        Icons.credit_card,
                        "Recharge sécurisé via Paypal",

                        "image_paypal.png",
                      ),
                      _buildPaymentOption(
                        "Mobile Money",
                        Icons.phone_android,
                        "Recharge rapide via M-Pesa, Airtel ou Orange",

                        "mobile.png",
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

  void showPhoneNumberInput(int refBanque) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height *
              0.65, // Augmenté à 55% pour plus de visibilité
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
              insertedLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                    icon: Icon(Icons.payment),
                    onPressed:
                        insertedLoading
                            ? null
                            : () {
                              if (phoneController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Veuillez entrer un numéro valide.",
                                    ),
                                  ),
                                );
                              } else {
                                storePaymentBackendMobile(refBanque);
                                // print(
                                //   "Paiement via $selectedMobileMoney avec numéro ${phoneController.text}",
                                // );

                                Navigator.pop(context);
                              }
                            },
                    label: Text("Confirmer"),
                  ),
            ],
          ),
        );
      },
    );
  }
}

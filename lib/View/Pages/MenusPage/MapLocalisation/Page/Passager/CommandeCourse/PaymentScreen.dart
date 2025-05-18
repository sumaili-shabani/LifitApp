import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/StripePaymentScreen.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe; // ✅ Alias ajouté
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
                        showMobileMoneyOptions(course);
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
      double montant = double.parse(widget.course.montantCourse.toString())/2850;
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
                          "name": widget.course.nomTypeCourse,
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

  void showMobileMoneyOptions(CourseInfoPassagerModel course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
         final l10n = AppLocalizations.of(context)!;
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
              Text(
                "${l10n.paiement_ui_select_operateur}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildMobileMoneyOption(
                context,
                "M-Pesa",
                "Vodacom",
                Icons.account_balance_wallet,
                Colors.white,
                "mpesa.png",
                course,
                2,
              ),
              _buildMobileMoneyOption(
                context,
                "Airtel Money",
                "Airtel",
                Icons.account_balance_wallet,
                Colors.white,
                "airtelmoney.png",
                course,
                3,
              ),
              _buildMobileMoneyOption(
                context,
                "Orange Money",
                "Orange",
                Icons.account_balance_wallet_rounded,
                Colors.white,
                "orangemoney.png",
                course,
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

      EasyLoading.show(
        status: 'Envoi en cours...',
        maskType: EasyLoadingMaskType.black,
      );
      setState(() {
        insertedLoading = true;
      });
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
    BuildContext context,
    String provider,
    String description,
    IconData icon,
    Color colorIcone,
    String imgFile,
    CourseInfoPassagerModel course,
    int refBanque,
  ) {
    final l10n = AppLocalizations.of(context)!;

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
          showPhoneNumberInput(course, refBanque);
        },
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${l10n.paiement_ui_montant}:",
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

  void showPhoneNumberInput(CourseInfoPassagerModel course, int refBanque) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
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
                "${l10n.paiement_ui_select_numberPhone}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "${l10n.paiement_ui_select_number_mobile_money}",
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
                                      "${l10n.paiement_ui_select_enter_number_phone}.",
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
                    label: Text("${l10n.paiement_ui_select_confirmer}"),
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
      'refCourse': widget.course.id!,
      'refBanque': refBanque,
      'montant_paie': widget.course.montantCourse!,
      'devise': widget.course.devise!,
      'date_paie': widget.course.dateCourse!,
      'libellepaie': "Paiement  ${widget.course.nomTypeCourse!}",
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(16),
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
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${l10n.paiement_ui_mode_paie}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${l10n.paiement_ui_mode_paie_selected} : $selectedPaymentMethod",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      _buildPaymentOption(
                        "Cash",
                        Icons.money,
                        "${l10n.paiement_ui_mode_marketing_1} ",
                        widget.course,
                        "Icon_cash.png",
                      ),
                      // _buildPaymentOption(
                      //   "Banque (Stripe)",
                      //   Icons.credit_card,
                      //   "${l10n.paiement_ui_mode_marketing_2} ",
                      //   widget.course,
                      //   "stripe.png",
                      // ),
                      // _buildPaymentOption(
                      //   "Banque (Paypal)",
                      //   Icons.credit_card,
                      //   "${l10n.paiement_ui_mode_marketing_3} ",
                      //   widget.course,
                      //   "image_paypal.png",
                      // ),
                      _buildPaymentOption(
                        "Mobile Money",
                        Icons.phone_android,
                        "${l10n.paiement_ui_mode_marketing_4} ",
                        widget.course,
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
}

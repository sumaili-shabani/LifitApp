import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CallApi {
  final String _url = 'https://www.swiftride.tech/api/';
  final String _imgUrl = 'https://www.swiftride.tech/';
  static String apiUrl = "https://www.swiftride.tech/api/";

  static String apiKey = "AIzaSyCCF6II62n7-ZB-ooj5M4PCr1v50SKxK-s";
  static String apikeyOpenrouteservice =
      "5b3ce3597851110001cf62484e660c3aa019470d8ac388d12b974480";
  static String pusherAppKey = "50a88f66ba9024781e33";
  static String stripePublicKey =
      "pk_test_51GzffmHcKfZ3B3C9QaTVyo3LLihTTvxeIB664wbvnFtpKks4ylxc4WmvEA6mcru78pEiiON2jaWhoAPCrDjBkOho004cS9mB9n";

  //paypal
  static String clientIDPaypal =
      "ARrOsUcRXDJbnsY-H421KnsJVMq-shlnw-jshSUOUhY7xWPPuAXMKavFcN_s5YRoLIHBPXbYErhPS3q0";
  static String secretkeyPaypal =
      "EMQwmfqdSwgHcspmS-V-jpweCEPbkNYXfp5O88MBa7N1tZSXK3DH2KF8bl_DXz_jXXz_-I9mbGB1Ynf6";
  static bool sandboxModePaypal = true;

  //par defaut en ligne
  // static const String fileUrl = "https://www.swiftride.tech/"; // Pour le fichier
  // static const String baseUrl = "https://www.swiftride.tech/api"; // Remplace par ton URL

  //  static const String fileUrl =
  //     "https://lifti.e-serv.org/"; // Pour le fichier
  // static const String baseUrl =
  //     "https://lifti.e-serv.org/api"; // Remplace par ton URL

  // par defaut en locale
  static const String fileUrl = "http://10.156.83.127:8000"; // Pour le fichier
  static const String baseUrl = "http://10.156.83.127:8000/api"; // pour ton URL

  /*
  *
  *============================
  * Api Methode
  *============================
  *
  */
  /// 🔹 **Méthode GET**
  static Future<Map<String, dynamic>> fetchData(String endpoint) async {
    String? token = await getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur lors de la récupération des données");
    }
  }

  static Future<List<dynamic>> fetchListData(String endpoint) async {
    String? token = await getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception("Erreur lors de la récupération des données");
    }
  }

  /// 🔹 **Méthode POST**
  static Future<Map<String, dynamic>> postData(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    String? token = await getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur lors de l'envoi des données");
    }
  }

  static Future<Map<String, dynamic>> deleteData(String endpoint) async {
    String? token = await getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur lors de la récupération des données");
    }
  }

  /// 🔹 **Méthode PUT**
  static Future<Map<String, dynamic>> updateData(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    String? token = await getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur lors de la mise à jour des données");
    }
  }

  static Future<Map<String, dynamic>> insertData({
    required String endpoint,
    required Map<String, dynamic> data,
    // required String token, // Passer le token ici
  }) async {
    String? token = await getToken();
    final String baseUrl = CallApi.baseUrl; // Remplace par ton URL

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/$endpoint"),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Accept": "application/json",
          "Authorization": "Bearer $token", // Token ajouté ici
        },
        body: json.encode(data),
      );

      // Vérification du statut de la réponse
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body); // Retourne les données de l'API
      } else {
        throw Exception("Erreur API ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Erreur d'insertion : $e");
      throw Exception("Erreur lors de l'insertion des données : $e");
    }
  }

  /// 🔹 **Méthode DELETE**
  // static Future<void> deleteData(String endpoint) async {
  //  String? token = await getToken();
  //   final response = await http.delete(
  //     Uri.parse("$baseUrl/$endpoint"),
  //     headers: {
  //       "Content-Type": "application/json; charset=UTF-8",
  //       'Accept': 'application/json',
  //        if (token != null) 'Authorization': 'Bearer $token',
  //     },
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception("Erreur lors de la suppression des données");
  //   }
  // }

  /*
  *
  *============================
  * Api Methode
  *============================
  *
  */

  getImage() {
    return _imgUrl;
  }

  static formatDateFrancais(mydate) {
    var inputFormat = DateFormat('yyyy-MM-dd HH:mm');
    var inputDate = inputFormat.parse(mydate);
    var outputFormat = DateFormat('dd/MM/yyyy HH:mm');
    return outputFormat.format(inputDate);
  }

  static String getFormatedDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(
        dateStr,
      ); // Convertir le string en DateTime
      return DateFormat(
        "dd MMMM yyyy",
        "fr_FR",
      ).format(date); // Formatter en français
    } catch (e) {
      return "Date invalide"; // Gestion d'erreur si la date est incorrecte
    }
  }

  static double arrondirChiffre(double value) {
    return double.parse(value.toStringAsFixed(5));
  }

  static String limitText(String text, int nombre) {
    if (text.length > 5) {
      return text.substring(0, nombre);
    } else {
      return text;
    }
  }

  static Color getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256), // Rouge (0-255)
      random.nextInt(256), // Vert (0-255)
      random.nextInt(256), // Bleu (0-255)
      1.0, // Opacité (1.0 = opaque)
    );
  }

  //le jour
  static String getCurrentDateTime() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return formattedDate;
  }

  static String getCurrentDateTimeWithOffset(double minutesToAdd) {
    DateTime now = DateTime.now().add(
      Duration(seconds: (minutesToAdd * 60).toInt()),
    );
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return formattedDate;
  }

  static String formatDateString(String dateString) {
    // Convertir la chaîne en DateTime
    DateTime date = DateTime.parse(dateString);

    // Créer un formatteur pour le format désiré
    final DateFormat formatter = DateFormat('d MMMM yyyy à HH:mm:ss');

    // Retourner la date formatée
    return formatter.format(date);
  }

  getData(baseUrl) async {
    // var fullUrl = _url + baseUrl + await getToken();
    var fullUrl = _url + baseUrl;
    return await http.get(Uri.parse(fullUrl), headers: _setHeaders());
  }

  _setHeaders() => {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<String?> getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return localStorage.getString('token');
  }

  static Future<String?> getNameConnected() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return localStorage.getString('nameConnected');
  }

  static Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(
      'idConnected',
    ); // Supposons que l'ID est stocké sous 'user_id'
  }

  static Future<int?> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(
      'idRoleConnected',
    ); // Supposons que l'ID est stocké sous 'user_id'
  }

  static Future<Map<String, dynamic>?> getCoordinates(String address) async {
    try {
      String nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
      final Uri url = Uri.parse(
        '$nominatimBaseUrl/search?q=$address&format=json&addressdetails=1&limit=1',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.isNotEmpty ? data[0] : null;
      } else {
        print('Erreur: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Erreur lors de la requête Nominatim: $error');
      return null;
    }
  }

  /*
  *
  * =======================
  * Mes scripts commance
  * =======================
  *
  */

  static insertOrUpdateData(url, Map pdata) async {
    try {
      String? token = await getToken();
      var res = await http.post(
        Uri.parse("${baseUrl.toString()}/${url.toString()}"),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(pdata),
      );

      return res;

      // if (res.statusCode == 200) {
      //   // var data = json.decode(res.body)['data'];
      //   var data = json.decode(res.body);
      //   return data;
      // } else {
      //   // var data = json.decode(res.body)['data'];
      //   var data = json.decode(res.body);
      //   return data;
      // }
    } catch (e) {
      throw Exception("Erreur lors de l'opération insert or update data: $e ");
    }
  }

  static getHeaders() async {
    String? token = await getToken();
    var headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    return headers;
  }

  static dynamic getValidDropdownValue(
    List<Map<String, dynamic>> items,
    dynamic value,
    String valueKey,
  ) {
    return items.any((item) => item[valueKey] == value) ? value : null;
  }

  static String generateEmail(String name) {
    // Nettoyage du nom : suppression des espaces, accents, mise en minuscule
    final cleanedName = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-') // espaces remplacés par des points
        .replaceAll(RegExp(r'[^a-z0-9.]'), ''); // supprime caractères spéciaux

    return "$cleanedName@demo.com";
  }


}

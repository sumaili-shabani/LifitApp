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

  //par defaut en ligne
  // static const String fileUrl = "https://www.swiftride.tech/"; // Pour le fichier
  // static const String baseUrl ="https://www.swiftride.tech/api"; // Remplace par ton URL

  //par defaut en locale
  static const String fileUrl = "http://10.52.50.127:8000"; // Pour le fichier
  static const String baseUrl =
      "http://10.52.50.127:8000/api"; // Remplace par ton URL

  /*
  *
  *============================
  * Api Methode
  *============================
  *
  */
  /// 🔹 **Méthode GET**
  static Future<Map<String, dynamic>> fetchData(String endpoint) async {
    final response = await http.get(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur lors de la récupération des données");
    }
  }

  static Future<List<dynamic>> fetchListData(String endpoint) async {
    final response = await http.get(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        'Accept': 'application/json',
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
    final response = await http.post(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        'Accept': 'application/json',
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
    final response = await http.get(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        'Accept': 'application/json',
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
    final response = await http.put(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        'Accept': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur lors de la mise à jour des données");
    }
  }

  /// 🔹 **Méthode DELETE**
  // static Future<void> deleteData(String endpoint) async {
  //   final response = await http.delete(
  //     Uri.parse("$baseUrl/$endpoint"),
  //     headers: {
  //       "Content-Type": "application/json; charset=UTF-8",
  //       'Accept': 'application/json',
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

  // postData(data, apiUrl) async {
  //   // var fullUrl = _url + apiUrl + await getToken();
  //   var fullUrl = _url + apiUrl;
  //   return await http.post(
  //     Uri.parse(fullUrl),
  //     body: jsonEncode(data),
  //     headers: _setHeaders(),
  //   );
  // }

  getData(apiUrl) async {
    // var fullUrl = _url + apiUrl + await getToken();
    var fullUrl = _url + apiUrl;
    return await http.get(Uri.parse(fullUrl), headers: _setHeaders());
  }

  _setHeaders() => {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    return token;
  }

  static Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(
      'idConnected',
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

  // getArticles(apiUrl) async {}
  // getPublicData(apiUrl) async {}

  /*
  *
  * =======================
  * Mes scripts commance
  * =======================
  *
  */

  static showMsg(String text) {
    // Fluttertoast.showToast(
    //   msg: text,
    //   toastLength: Toast.LENGTH_SHORT,
    //   gravity: ToastGravity.BOTTOM, // Position at bottom
    //   backgroundColor: Colors.green,
    //   textColor: Colors.white,
    // );
  }

  static showErrorMsg(String text) {
    // Fluttertoast.showToast(
    //   msg: text,
    //   toastLength: Toast.LENGTH_SHORT,
    //   gravity: ToastGravity.BOTTOM, // Position at bottom
    //   backgroundColor: Colors.red,
    //   textColor: Colors.white,
    // );
  }

  static insertOrUpdateData(url, Map pdata) async {
    try {
      final res = await http.post(
        Uri.parse("${apiUrl.toString()}${url.toString()}"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(pdata),
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body)['data'];
        showMsg(data.toString());
      } else {
        showErrorMsg("Erreur de modification des données!!!");
        return res;
      }
    } catch (e) {
      showErrorMsg(e.toString());
    }
  }

  // static deleteData(url, int id) async {
  //   try {
  //     final res = await http.get(
  //       Uri.parse("${apiUrl.toString()}${url.toString()}/${id.toInt()}"),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //     );

  //     if (res.statusCode == 200) {
  //       var data = jsonDecode(res.body)['data'];
  //       showMsg(data.toString());
  //     } else {
  //       showErrorMsg("Erreur de supprimer les données!!!");
  //     }
  //   } catch (e) {
  //     showErrorMsg(e.toString());
  //   }
  // }

  static postArticle(Map pdata) async {
    try {
      final res = await http.post(
        Uri.parse("${apiUrl}insert_article"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: pdata,
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body)['data'];
        showMsg(data.toString());
        // print(data);
      } else {
        showErrorMsg("Erreur de charger les données!!!");
      }
    } catch (e) {
      showErrorMsg(e.toString());
    }
  }

  // static getArticle() async {
  //   List<Article> article = [];
  //   try {
  //     final res = await http.get(
  //       Uri.parse("${apiUrl}fetch_article_mobile"),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //     );

  //     if (res.statusCode == 200) {
  //       var data = jsonDecode(res.body);

  //       data['data'].forEach((value) => {
  //             article.add(
  //               Article(
  //                 value['id'],
  //                 value['title'],
  //                 value['description'],
  //                 value['created_at'],
  //               ),
  //             )
  //           });
  //       return article;
  //     } else {
  //       return [];
  //     }
  //   } catch (e) {
  //     showErrorMsg(e.toString());
  //   }
  // }
}
